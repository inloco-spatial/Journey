Shader "Custom/CutoutTwoSidedFakeLightFog" {
    Properties {
        _MainTex ("Base (RGBA)", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
        _FakeLightColor ("Fake Light Color", Color) = (1,1,1,1)
        _FakeLightDir ("Fake Light Direction", Vector) = (0,1,0,0)
        _FogColor ("Custom Fog Color", Color) = (0.5,0.5,0.5,1)
        _FogDensity ("Custom Fog Density", Range(0,1)) = 0.1
        _EmissionMap ("Emission Map (RGB)", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _EmissionStrength ("Emission Strength", Range(0,8)) = 1.0
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Range(0.1,10)) = 1.0
        _NoiseSpeed ("Noise Speed", Range(0,5)) = 1.0
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.5
    }
    SubShader {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        Cull Off
        Lighting Off
        ZWrite On
        Blend Off
        Pass {
            Fog { Mode Off }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float4 _FakeLightColor;
            float4 _FakeLightDir;
            float4 _FogColor;
            float _FogDensity;
            sampler2D _EmissionMap;
            float4 _EmissionMap_ST;
            float4 _EmissionColor;
            float _EmissionStrength;
            sampler2D _NoiseTex;
            float _NoiseScale;
            float _NoiseSpeed;
            float _NoiseStrength;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // Base texture and cutout
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);

                // Fake lighting
                float3 lightDir = normalize(_FakeLightDir.xyz);
                float NdotL = saturate(dot(normalize(i.worldNormal), lightDir));
                col.rgb *= lerp(0.2, 1.0, NdotL) * _FakeLightColor.rgb;

                // Emission base
                fixed4 emi = tex2D(_EmissionMap, i.uv) * _EmissionColor;
                
                // Animated noise modulation
                float2 noiseUV = i.uv * _NoiseScale + _Time.y * _NoiseSpeed;
                float noiseVal = tex2D(_NoiseTex, noiseUV).r;
                float noiseMod = lerp(1.0 - _NoiseStrength, 1.0, noiseVal);
                emi.rgb *= noiseMod;
                
                // Pulse (overall emission pulsation)
                float pulse = 0.5 + 0.5 * sin(_Time.y * _NoiseSpeed * 0.5);
                emi.rgb *= pulse;

                // Apply emission
                col.rgb += emi.rgb * _EmissionStrength;

                // Custom fog
                float dist = length(_WorldSpaceCameraPos - i.worldPos);
                float fogFactor = 1.0 - exp(-_FogDensity * _FogDensity * dist * dist);
                col.rgb = lerp(col.rgb, _FogColor.rgb, fogFactor);

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}