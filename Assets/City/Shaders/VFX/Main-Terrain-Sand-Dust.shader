Shader "Custom/TerrainFogBlend_TintTerrain"
{
    Properties
    {
        // Height-based gradient
        _HeightColorLow     ("Low Height Color",      Color) = (1,0.85,0.65,1)
        _HeightColorHigh    ("High Height Color",     Color) = (1,0.92,0.75,1)
        _HeightStart        ("Height Start (m)",      Float) = 0.0
        _HeightEnd          ("Height End (m)",        Float) = 20.0

        // Terrain tint by distance/density
        _TerrainTintColor   ("Terrain Tint Color",    Color) = (1,0.9,0.8,1)
        // эти же параметры управляют интенсивностью tint
        _FogDistance        ("Tint & Fog Distance",   Float) = 40.0
        _FogDensity         ("Tint & Fog Density",    Range(0.1,5)) = 1.5

        // Volumetric fog
        _FogColor            ("Fog Color",             Color) = (0.1,0.1,0.1,1)

        // Height-layered fog at ground
        _HeightFogMaxY       ("Height Fog Max Y",      Float) = 5.0
        _HeightFogStrength   ("Height Fog Strength",   Range(0,1)) = 0.7

        // Desaturation by distance
        _DesatStrength       ("Desaturation Strength", Range(0,1)) = 0.5

        // Noise for fog
        _NoiseTex            ("Noise Texture",         2D)    = "white" {}
        _NoiseScale          ("Noise Scale",           Range(0.1,10))= 2.0
        _NoiseSpeed          ("Noise Speed",           Range(0,5))   = 0.1
        _NoiseStrength       ("Noise Strength",        Range(0,1))   = 0.3

        // Fade terrain under objects
        _FadeDistance        ("Object Fade Distance",  Float) = 3.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "TerrainCompatible" = "true"}
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

            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "UnityCG.cginc" 


            // Gradients
            float4 _HeightColorLow, _HeightColorHigh;
            float  _HeightStart, _HeightEnd;

            // Terrain tint params (shared with fog)
            float4 _TerrainTintColor;
            float  _FogDistance, _FogDensity;

            // Fog
            float4 _FogColor;
            float  _HeightFogMaxY, _HeightFogStrength;
            float  _DesatStrength;

            sampler2D _NoiseTex; float _NoiseScale, _NoiseSpeed, _NoiseStrength;
            float  _FadeDistance;

            struct Attributes
            {
                float4 posOS : POSITION;
            };
            struct Varyings
            {
                float4 posH   : SV_POSITION;
                float3 posWS  : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
            };
            /*
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.posH    = TransformObjectToHClip(IN.posOS.xyz);
                OUT.posWS   = TransformObjectToWorld(IN.posOS.xyz);
                OUT.scrPos  = ComputeScreenPos(OUT.posH);
                return OUT;
            }
            */

            half4 frag(Varyings IN) : SV_Target
            {
                // 1) Height gradient
                float hNorm = saturate((IN.posWS.y - _HeightStart) / (_HeightEnd - _HeightStart));
                float3 baseCol = lerp(_HeightColorLow.rgb, _HeightColorHigh.rgb, hNorm);

                // 2) Linear eye depth
                float depth = LinearEyeDepth( _ZBufferParams);
                //float depth = LinearEyeDepth(IN.posH.z, _ZBufferParams);

                // 3) Terrain tint by distance/density
                float terrainTintFactor = pow(saturate(depth / _FogDistance), 1.0 / _FogDensity);
                baseCol = lerp(baseCol, _TerrainTintColor.rgb, terrainTintFactor);

                // 4) Height-layered fog at ground
                float heightFog = clamp((_HeightFogMaxY - IN.posWS.y) / _HeightFogMaxY, 0, 1) 
                                  * _HeightFogStrength;

                // 5) Volumetric fog + noise
                float baseFog  = saturate(depth / _FogDistance);
                float2 nUV     = IN.scrPos.xy / IN.scrPos.w * _NoiseScale + _Time.y * _NoiseSpeed;
                float noise    = (tex2D(_NoiseTex, nUV).r - 0.5) * _NoiseStrength;
                float fogFactor = saturate(baseFog + heightFog + noise);
                fogFactor       = pow(fogFactor, 1.0 / _FogDensity);
                baseCol         = lerp(baseCol, _FogColor.rgb, fogFactor);

                // 6) Desaturation by distance
                float gray     = dot(baseCol, float3(0.3, 0.59, 0.11));
                float desatF   = saturate(depth / _FogDistance) * _DesatStrength;
                baseCol        = lerp(baseCol, gray.xxx, desatF);

                // 7) Fade terrain under objects
                //float sceneD   = SampleSceneDepth(IN.scrPos.xy / IN.scrPos.w);
                UNITY_TRANSFER_DEPTH(IN.scrPos.xy / IN.scrPos.w);
                //float sceneLin = LinearEyeDepth(sceneD, _ZBufferParams);
                float sceneLin = LinearEyeDepth( _ZBufferParams);

                float diff     = depth - sceneLin;
                float alpha    = saturate(smoothstep(0, _FadeDistance, diff));

                return float4(baseCol, alpha);
            }
            ENDHLSL
        }
    }
}
