Shader "Custom/DreamySandDepthBlend_Stars"
{
    Properties
    {
        // Base sand appearance
        _BaseMap ("Base Texture", 2D) = "white" {}
        _BaseColor ("Tint Color", Color) = (1,1,1,1)

        _BottomColor ("Bottom Sand Color", Color) = (1, 0.85, 0.65, 1)
        _TopColor    ("Top Sand Color",    Color) = (1, 0.92, 0.75, 1)

        // Atmospheric far-distance tint
        _FarColor     ("Far Tint Color", Color) = (1, 0.9, 0.8, 1)
        _FarDistance  ("Far Tint Start Distance", Float) = 30.0

        // Wavy border animation
        _NoiseTex     ("Noise Texture", 2D) = "white" {}
        _NoiseStrength("Noise Strength", Range(0,2)) = 0.5
        _NoiseSpeed   ("Noise Scroll Speed", Range(0,5)) = 0.2
        _NoiseScale   ("Noise Scale",  Range(0.1, 10)) = 3.0

        // Depth fade
        _DepthFadeDistance ("Depth Fade Distance", Float) = 1.0

        // ✧ Sparkling sand‑spray parameters ✧
        _StarColor        ("Spray Color", Color) = (1, 1, 0.8, 1)
        _StarDensity      ("Spray Density", Range(0,1)) = 0.15     // 0 = off, 1 = full coverage
        _StarGlow         ("Spray Glow", Range(0,5)) = 2.0          // emissive multiplier
        _StarNoiseScale   ("Spray Noise Scale", Range(0.1,100)) = 30 // controls granularity of dots
        _StarFlickerSpeed ("Spray Flicker Speed", Range(0,10)) = 3.0 // speed of twinkle
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 300
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            // ----- textures & colors -----
            sampler2D _BaseMap;       float4 _BaseMap_ST;
            float4    _BaseColor;

            float4 _BottomColor;
            float4 _TopColor;

            float4 _FarColor;   float  _FarDistance;

            sampler2D _NoiseTex;            // reused for star placement & flicker
            float _NoiseStrength;  float _NoiseSpeed;  float _NoiseScale;

            float _DepthFadeDistance;

            // ✧ Spray parameters ✧
            float4 _StarColor;
            float  _StarDensity;
            float  _StarGlow;
            float  _StarNoiseScale;
            float  _StarFlickerSpeed;

            struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
            struct Varyings   { float4 positionHCS : SV_POSITION; float3 positionWS : TEXCOORD0; float2 uv : TEXCOORD1; float4 screenPos : TEXCOORD2; };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv          = IN.uv;
                OUT.screenPos   = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // ------------------------------------------------------------
                // Base dune color & texture
                float height = IN.positionWS.y;
                float gradientFactor = saturate(height * 0.1);  // 0 bottom, 1 top
                float4 sandColor = lerp(_BottomColor, _TopColor, gradientFactor);

                float2 baseUV    = IN.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                float4 baseTex   = tex2D(_BaseMap, baseUV) * _BaseColor;
                float4 finalCol  = baseTex * sandColor;

                // Distance tint
                float depth       = LinearEyeDepth(IN.positionHCS.z, _ZBufferParams);
                float farFactor   = saturate(depth / _FarDistance);
                finalCol.rgb      = lerp(finalCol.rgb, _FarColor.rgb, farFactor);

                // Edge noise for blending
                float2 noiseUV    = IN.uv * _NoiseScale + float2(_Time.y * _NoiseSpeed, _Time.y * _NoiseSpeed);
                float edgeNoise   = tex2D(_NoiseTex, noiseUV).r;
                float noiseFactor = (edgeNoise - 0.5) * 2.0 * _NoiseStrength;

                // Depth fade against geometry
                float2 screenUV   = IN.screenPos.xy / IN.screenPos.w;
                float sceneDepth  = SampleSceneDepth(screenUV);
                float sceneLin    = LinearEyeDepth(sceneDepth, _ZBufferParams);
                float pixelLin    = LinearEyeDepth(IN.positionHCS.z, _ZBufferParams);

                float depthDiff   = sceneLin - pixelLin;
                float depthFade   = saturate(depthDiff / _DepthFadeDistance);
                float finalAlpha  = 1.0;
                if (depthDiff > 0.0 && depthDiff < _DepthFadeDistance)
                    finalAlpha = saturate(depthFade + noiseFactor);

                // ------------------------------------------------------------
                // ✧ Twinkling spray effect ✧
                // Active mainly on crest & slope tops for highlight
                float crestMask     = smoothstep(0.65, 0.85, gradientFactor); // soft activation zone

                // Noise value reused for dot selection (gives discrete dots)
                float dotNoise      = tex2D(_NoiseTex, IN.uv * _StarNoiseScale).r;
                float dotMask       = step(1.0 - _StarDensity, dotNoise) * crestMask;

                // A second noise sample (offset UV) introduces random phase per dot for flicker
                float phaseNoise    = tex2D(_NoiseTex, IN.uv * (_StarNoiseScale * 0.7) + float2(0.37, 0.53)).r;
                float flicker       = 0.5 + 0.5 * sin(_Time.y * _StarFlickerSpeed + phaseNoise * 6.28318);

                float sprayInt      = dotMask * _StarGlow * flicker;
                finalCol.rgb       += _StarColor.rgb * sprayInt;

                return float4(finalCol.rgb, finalAlpha);
            }
            ENDHLSL
        }
    }
}
