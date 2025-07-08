Shader "Custom/MirageAlphaRevealMagic"
{
    Properties
    {
        _MainTex("Base Texture (optional)", 2D) = "white" {}
        _AlphaMap("Alpha Mask (B/W)", 2D) = "white" {}
        // 0 → show full mask; 1 → fully transparent
        _MaskThreshold("Fade Out Mask", Range(0,1)) = 0.0
        _EmissionIntensity("Emission Intensity", Float) = 5.0
        _Color("Emission Color", Color) = (0.6,0.9,1.0,1)
        _Pulse("Heartbeat Pulse", Range(0,1)) = 0.0
        _FlickerSpeed("Flicker Speed", Float) = 4.0
        _FlickerIntensity("Flicker Intensity", Range(0,1)) = 0.5
        _RevealNoiseScale("Reveal Noise Scale", Float) = 8.0
        _DistortStrength("Distortion Strength", Range(0,0.1)) = 0.02
        _StarFrequency("Star Frequency", Float) = 30.0
        _StarThreshold("Star Brightness Threshold", Range(0,1)) = 0.9
        _StarSize("Star Size", Float) = 0.02
        _ChromaOffset("Chromatic Offset", Float) = 0.003
        _TrailIntensity("Light Trail Intensity", Float) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Off
        LOD 250
        ZWrite Off
        Blend SrcAlpha One

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);
            TEXTURE2D(_AlphaMap);   SAMPLER(sampler_AlphaMap);

            float _MaskThreshold;
            float _EmissionIntensity;
            float4 _Color;
            float _Pulse;
            float _FlickerSpeed;
            float _FlickerIntensity;
            float _RevealNoiseScale;
            float _DistortStrength;
            float _StarFrequency;
            float _StarThreshold;
            float _StarSize;
            float _ChromaOffset;
            float _TrailIntensity;

            struct Attributes { float4 posOS:POSITION; float2 uv:TEXCOORD0; };
            struct Varyings  { float4 posCS:SV_POSITION; float2 uvMain:TEXCOORD0; float2 uvMask:TEXCOORD1; };

            float hash(float2 p) { p = frac(p * float2(5.3983,5.4427)); p+=dot(p,p+3.5453); return frac(p.x*p.y); }
            float noise(float2 p) {
                float2 i=floor(p), f=frac(p);
                float2 u=f*f*(3-2*f);
                return lerp(lerp(hash(i),    hash(i+float2(1,0)),u.x),
                            lerp(hash(i+float2(0,1)),hash(i+float2(1,1)),u.x), u.y);
            }
            float starMask(float2 uv) {
                float n = noise(uv * _StarFrequency);
                return step(_StarThreshold, n) * smoothstep(_StarThreshold,1,n) * _StarSize;
            }

            Varyings Vert(Attributes IN) {
                Varyings OUT;
                OUT.posCS  = TransformObjectToHClip(IN.posOS.xyz);
                OUT.uvMain = IN.uv;
                OUT.uvMask = IN.uv;
                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target {
                float t = _Time.y;
                float2 uv = IN.uvMask;

                // wind-like distortion
                float d = (noise(uv*10 + t) - 0.5)*2*_DistortStrength;
                uv += float2(d, d*0.5);

                // sample mask
                float maskV = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, uv).r;

                // compute global fade: at 0 show full mask, at 1 hide completely
                float fade = saturate(1 - _MaskThreshold);

                // flicker + pulse
                float fn = noise(float2(t*_FlickerSpeed, uv.y*_RevealNoiseScale));
                float flick = saturate(1 + (fn-0.5)*2*_FlickerIntensity) * lerp(1,1.5,_Pulse);

                // trail sparkle along mask edge
                float trail = smoothstep(0.01, 0.0, abs(maskV - fade))*_TrailIntensity;

                // star sparks at edge
                float starEdge = smoothstep(0.01, 0.0, abs(maskV - fade));
                float star = starMask(uv) * starEdge;

                // emission
                float3 emission = _Color.rgb * maskV * flick * _EmissionIntensity * fade;
                emission += _Color.rgb * trail * 0.5;
                emission += _Color.rgb * star;

                // chromatic aberration
                float2 co=uv;
                float3 ca;
                ca.r = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, co+float2(_ChromaOffset*_Pulse,0)).r;
                ca.g = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, co).r;
                ca.b = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, co-float2(_ChromaOffset*_Pulse,0)).r;
                float3 color = lerp(ca, emission, 0.7) * fade;

                return half4(color, fade * maskV);
            }
            ENDHLSL
        }
    }
    Fallback "Hidden/BlitCopy"
}
