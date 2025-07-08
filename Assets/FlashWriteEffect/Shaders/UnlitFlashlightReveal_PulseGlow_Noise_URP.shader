Shader "Custom/UnlitFlashlightReveal_PulseGlow_Noise_URP"
{
    Properties
    {
        _MainTex           ("AlphaMask",            2D)    = "white" {}
        _NoiseTex          ("NoiseTex",             2D)    = "white" {}
        _NoiseScale        ("NoiseScale",           Float) = 10
        _NoiseStrength     ("NoiseStrength",        Range(0,0.5)) = 0.05
        _BaseColor         ("BaseColor",            Color) = (1,1,1,1)
        _GlowColor         ("GlowColor",            Color) = (1,1,0.5,1)
        _EdgeWidth         ("EdgeWidth",            Range(0.001,1)) = 0.02
        _BaseGlowIntensity ("BaseGlowIntensity",    Range(0,10)) = 1.5
        _GlowIntensity     ("GlowIntensity",        Range(0,20)) = 6
        _Radius            ("Radius",               Range(0,1)) = 0
        _HeartbeatRate     ("HeartbeatRate",        Float) = 60
        _PulseAmount       ("PulseAmount",          Range(0,2)) = 1
        _LightPos          ("LightPos (UV)",        Vector) = (0.5,0.5,0,0)
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            float _NoiseScale;
            float _NoiseStrength;
            float4 _BaseColor;
            float4 _GlowColor;
            float _EdgeWidth;
            float _BaseGlowIntensity;
            float _GlowIntensity;
            float _Radius;
            float4 _LightPos;
            float _HeartbeatRate;
            float _PulseAmount;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float alphaMask = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).r;
                float dist = distance(IN.uv, _LightPos.xy);

                float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, IN.uv * _NoiseScale + _Time.y * 0.1).r;
                float noisyDist = dist + (noise - 0.5) * _NoiseStrength;

                float reveal = smoothstep(_Radius, _Radius - _EdgeWidth, noisyDist);
                float baseAlpha = reveal * alphaMask;

                float edge = smoothstep(_Radius - _EdgeWidth, _Radius, noisyDist)
                           - smoothstep(_Radius, _Radius + _EdgeWidth, noisyDist);

                float pulse = abs(sin(_Time.y * (_HeartbeatRate / 60) * 6.2831853));
                pulse = lerp(1.0, pulse, _PulseAmount);

                float3 edgeGlow = _GlowColor.rgb * edge * _GlowIntensity * pulse;
                float3 baseGlow = _GlowColor.rgb * alphaMask * _BaseGlowIntensity * pulse;

                float3 col = _BaseColor.rgb * baseAlpha;
                float3 glow = edgeGlow + baseGlow;

                return float4(col + glow, baseAlpha);
            }
            ENDHLSL
        }
    }
}