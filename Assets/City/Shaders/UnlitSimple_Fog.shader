Shader "Custom/UnlitSimple_Fog_CubeRefl_Emissive"
{
    Properties
    {
        _BaseMap        ("Base Map", 2D)        = "white" {}
        _BaseColor      ("Base Color", Color)   = (1,1,1,1)
        _BumpMap        ("Normal Map", 2D)      = "bump" {}
        _NormalStrength ("Normal Map Strength", Range(0,2)) = 1.0
        _AOMap          ("Ambient Occlusion Map", 2D) = "white" {}
        _AOStrength     ("AO Strength", Range(0,1)) = 0.5

        _Cube           ("Reflection Cubemap", Cube) = "" {}
        _ReflStrength   ("Reflection Strength", Range(0,1)) = 0.3

        _EmissiveMap    ("Emissive Map", 2D)     = "black" {}
        _EmissiveColor  ("Emissive Color", Color)= (1,1,1,1)
        _EmissiveStrength ("Emissive Strength", Range(0,10)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            Name "UnlitWithFogReflEmissive"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // --- Textures & Samplers ---
            TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);        SAMPLER(sampler_BumpMap);
            TEXTURE2D(_AOMap);          SAMPLER(sampler_AOMap);
            TEXTURECUBE(_Cube);         SAMPLER(sampler_Cube);
            TEXTURE2D(_EmissiveMap);    SAMPLER(sampler_EmissiveMap);

            float4 _BaseColor;
            float  _NormalStrength;
            float  _AOStrength;
            float  _ReflStrength;
            float4 _EmissiveColor;
            float  _EmissiveStrength;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float3 tangentWS   : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 viewDirWS   : TEXCOORD4;
                float  fogCoord    : TEXCOORD5;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // позиция
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);

                // мировые векторы
                float3 worldPos   = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS      = TransformObjectToWorldNormal(IN.normalOS);
                OUT.tangentWS     = TransformObjectToWorldDir(IN.tangentOS.xyz);
                OUT.bitangentWS   = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                // направление на камеру
                OUT.viewDirWS = GetWorldSpaceViewDir(worldPos);

                // UV
                OUT.uv = IN.uv;

                // туман
                OUT.fogCoord = ComputeFogFactor(OUT.positionHCS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // --- Base + AO ---
                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                half ao = SAMPLE_TEXTURE2D(_AOMap, sampler_AOMap, IN.uv).r;
                ao = lerp(1.0, ao, _AOStrength);
                half3 colorAO = baseCol.rgb * ao;

                // --- Normal map ---
                half3 nTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv));
                nTS.xy *= _NormalStrength;
                nTS = normalize(nTS);
                half3x3 TBN = half3x3(
                    normalize(IN.tangentWS),
                    normalize(IN.bitangentWS),
                    normalize(IN.normalWS)
                );
                half3 normalWS = normalize(mul(nTS, TBN));

                // --- Reflection ---
                half3 R = reflect(-normalize(IN.viewDirWS), normalWS);
                half3 reflCol = SAMPLE_TEXTURECUBE(_Cube, sampler_Cube, R).rgb;
                half3 colorRefl = lerp(colorAO, reflCol, _ReflStrength);

                // --- Emissive ---
                half3 emissiveMap = SAMPLE_TEXTURE2D(_EmissiveMap, sampler_EmissiveMap, IN.uv).rgb;
                half3 emissiveCol = emissiveMap * _EmissiveColor.rgb * _EmissiveStrength;

                // --- Combine & Fog ---
                half3 combined = colorRefl + emissiveCol;
                half3 finalColor = MixFog(combined, IN.fogCoord);

                return half4(finalColor, baseCol.a);
            }
            ENDHLSL
        }
    }
}
