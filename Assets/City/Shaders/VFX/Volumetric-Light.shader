Shader "Custom/VolumetricWindowLight"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 0.9, 0.6, 1)
        _Opacity ("Opacity", Range(0,1)) = 0.5
        _FalloffDistance ("Falloff Distance", Float) = 2.0
        _VolumeCenter ("Volume Center", Vector) = (0,0,0,0)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Float) = 1.0
        _NoiseTiling ("Noise Tiling (Base,Freq)", Vector) = (1,1,0,0)
        _UseNoiseAnim ("Animate Noise", Float) = 1
        _NoiseAnimSpeed ("Noise Anim Speed", Float) = 1.0
        _NoiseAnimAmp ("Noise Anim Amplitude", Float) = 1.0
        _NoiseIntensity ("Noise Intensity", Range(0,1)) = 0.2
        _GlowIntensity ("Glow Intensity", Range(0,10)) = 1.0

        // Albedo UV Animation
        _UseAlbedoAnim ("Animate Albedo UV", Float) = 0
        _AlbedoTilingBase ("Albedo Base Tiling", Float) = 1.0
        _AlbedoAnimAmp ("Albedo Anim Amplitude", Float) = 0.1
        _AlbedoAnimFreq ("Albedo Anim Frequency", Float) = 1.0
        _AlbedoAnimSpeed ("Albedo Anim Speed", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off
        Blend SrcAlpha One
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _Opacity;
            float _FalloffDistance;
            float3 _VolumeCenter;

            sampler2D _NoiseTex;
            float _NoiseScale;
            float4 _NoiseTiling;
            float _UseNoiseAnim;
            float _NoiseAnimSpeed;
            float _NoiseAnimAmp;
            float _NoiseIntensity;
            float _GlowIntensity;

            float _UseAlbedoAnim;
            float _AlbedoTilingBase;
            float _AlbedoAnimAmp;
            float _AlbedoAnimFreq;
            float _AlbedoAnimSpeed;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // compute time
                float time = _Time.y;

                // Albedo UV tiling animation
                float2 uv = i.uv;
                if (_UseAlbedoAnim > 0.5)
                {
                    float uvLen = length(uv);
                    float anim = sin(uvLen * _AlbedoAnimFreq + time * _AlbedoAnimSpeed) * _AlbedoAnimAmp;
                    float tiling = _AlbedoTilingBase + anim;
                    uv *= tiling;
                }

                // sample Albedo
                float4 tex = tex2D(_MainTex, uv);
                float3 col = _Color.rgb * tex.rgb;
                float baseAlpha = tex.a * _Opacity;

                // Distance falloff
                float dist = distance(i.worldPos, _VolumeCenter);
                float falloff = saturate(1.0 - dist / _FalloffDistance);

                // Fresnel
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float fresnel = pow(1.0 - saturate(dot(normalize(i.normalDir), viewDir)), 3.0);

                // Noise UV tiling animation
                float2 noiseUV = i.worldPos.xz * _NoiseScale * _NoiseTiling.xy;
                if (_UseNoiseAnim > 0.5)
                {
                    float uvLenN = length(i.uv);
                    float animN = sin(uvLenN * _NoiseTiling.y + time * _NoiseAnimSpeed) * _NoiseAnimAmp;
                    noiseUV *= (1 + animN);
                }
                noiseUV += time * _UseNoiseAnim;
                float noise = (tex2D(_NoiseTex, noiseUV).r - 0.5) * 2.0;
                float noiseMod = 1.0 + noise * _NoiseIntensity;

                // combine alpha
                float alpha = baseAlpha * falloff * (0.3 + 0.7 * fresnel) * noiseMod;

                // apply glow
                float3 emission = col * alpha * _GlowIntensity;
                return float4(emission, alpha);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
