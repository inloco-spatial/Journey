// Terrain shader: fog blend and fade under objects (corrected fade direction)
Shader "Custom/TerrainFogBlend_UnderObjects"
{
    Properties
    {
        // Base sand texture
        _BaseMap          ("Base Texture",          2D)    = "white" {}
        _BaseColor        ("Tint Color",            Color) = (1,1,1,1)

        // Sand gradient
        _BottomColor      ("Bottom Sand Color",     Color) = (1,0.85,0.65,1)
        _TopColor         ("Top Sand Color",        Color) = (1,0.92,0.75,1)

        // Far tint
        _FarColor         ("Far Tint Color",        Color) = (1,0.9,0.8,1)
        _FarDistance      ("Far Tint Start Dist.",  Float) = 20.0

        // Fog
        _FogColor         ("Fog Color",             Color) = (0.9,0.9,1.0,1)
        _FogDensity       ("Fog Density",           Range(0,5))   = 1.5
        _FogDistance      ("Fog Fade Distance",     Float) = 40.0

        // Edge-vignette
        _EdgeStart        ("Vignette Start",        Range(0,0.5)) = 0.3
        _EdgeThickness    ("Vignette Width",        Range(0,0.5)) = 0.2

        // Noise
        _NoiseTex         ("Noise Texture",         2D)    = "white" {}
        _NoiseScale       ("Noise Scale",           Range(0.1,10))= 2.0
        _NoiseSpeed       ("Noise Speed",           Range(0,5))   = 0.1
        _NoiseStrength    ("Noise Strength",        Range(0,1))   = 0.3

        // Fade under objects
        _FadeDistance     ("Object Fade Distance",  Float) = 3.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _BottomColor, _TopColor;
            float4 _FarColor; float _FarDistance;
            float4 _FogColor; float _FogDensity, _FogDistance;
            float _EdgeStart, _EdgeThickness;
            sampler2D _NoiseTex; float _NoiseScale, _NoiseSpeed, _NoiseStrength;
            float _FadeDistance;

            struct Attributes { float4 posOS : POSITION; float2 uv : TEXCOORD0; };
            struct Varyings { float4 posH : SV_POSITION; float3 posWS : TEXCOORD0; float2 uv : TEXCOORD1; float4 scrPos : TEXCOORD2; };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.posH   = TransformObjectToHClip(IN.posOS.xyz);
                OUT.posWS  = TransformObjectToWorld(IN.posOS.xyz);
                OUT.uv     = IN.uv;
                OUT.scrPos = ComputeScreenPos(OUT.posH);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Base color and sand gradient
                float height = IN.posWS.y;
                float grad   = saturate(height * 0.1);
                float4 sand  = lerp(_BottomColor, _TopColor, grad);

                float2 uv = IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                float4 baseCol = tex2D(_BaseMap, uv) * _BaseColor;
                half4 col = baseCol * sand;

                // Far tint
                float depth = LinearEyeDepth(IN.posH.z, _ZBufferParams);
                col.rgb = lerp(col.rgb, _FarColor.rgb, saturate(depth / _FarDistance));

                // Volumetric fog with noise
                float fogF = saturate(depth / _FogDistance);
                float2 nUV = IN.scrPos.xy/IN.scrPos.w * _NoiseScale + _Time.y * _NoiseSpeed;
                fogF = saturate(fogF + (tex2D(_NoiseTex, nUV).r - 0.5) * _NoiseStrength);
                col.rgb = lerp(col.rgb, _FogColor.rgb, fogF * _FogDensity);

                // Vignette
                float2 sUV = IN.scrPos.xy/IN.scrPos.w;
                float vign  = smoothstep(_EdgeStart, _EdgeStart + _EdgeThickness, distance(sUV, float2(0.5,0.5)));
                col.rgb = lerp(col.rgb, _FogColor.rgb, vign);

                // Fade terrain under objects (inverted)
                float sceneD   = SampleSceneDepth(IN.scrPos.xy / IN.scrPos.w);
                float sceneLin = LinearEyeDepth(sceneD, _ZBufferParams);
                float diff     = depth - sceneLin;
                // invert fade: under object fully transparent (diff>0), fade back to opaque as diff increases
                float fadeTerr = smoothstep(0, _FadeDistance, diff);
                float alpha    = saturate(fadeTerr);

                return float4(col.rgb, alpha);
            }
            ENDHLSL
        }
    }
}