Shader "Custom/LitSimple_Fog"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Map Strength", Range(0, 2)) = 1.0
        _AOMap ("Ambient Occlusion Map", 2D) = "white" {}
        _AOStrength ("AO Strength", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300
        Cull off

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // --- Samplers & Uniforms ---
            sampler2D _BaseMap;
            sampler2D _BumpMap;
            sampler2D _AOMap;

            float4 _BaseColor;
            float _NormalStrength;
            float _AOStrength;

            // --- Vertex Data ---
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                float4 tangentOS  : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float2 uv          : TEXCOORD1;
                float3 normalWS    : TEXCOORD2;
                float3 tangentWS   : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float  fogCoord    : TEXCOORD5;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);

                OUT.normalWS   = TransformObjectToWorldNormal(IN.normalOS);
                OUT.tangentWS  = TransformObjectToWorldDir(IN.tangentOS.xyz);
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                OUT.uv = IN.uv;
                OUT.fogCoord = ComputeFogFactor(OUT.positionHCS.z);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // --- Textures & Materials ---
                half4 baseCol = tex2D(_BaseMap, IN.uv) * _BaseColor;
                half  ao      = tex2D(_AOMap,  IN.uv).r; // AO in red
                ao = lerp(1.0, ao, _AOStrength);

                // --- Normal mapping ---
                half3 nTS  = UnpackNormal(tex2D(_BumpMap, IN.uv));
                nTS.xy *= _NormalStrength;
                nTS = normalize(nTS);

                half3x3 TBN = half3x3(normalize(IN.tangentWS), normalize(IN.bitangentWS), normalize(IN.normalWS));
                half3 nWS = normalize(mul(nTS, TBN));

                // --- Lighting ---
                InputData inputData = (InputData)0;
                inputData.positionWS      = IN.positionWS;
                inputData.normalWS        = nWS;
                inputData.viewDirectionWS = GetWorldSpaceViewDir(IN.positionWS);
                inputData.shadowCoord     = TransformWorldToShadowCoord(IN.positionWS);
                inputData.fogCoord        = IN.fogCoord;

                half3 bakedGI = SampleSH(nWS);

                Light mainLight = GetMainLight(inputData.shadowCoord);
                half  NdotLMain = saturate(dot(nWS, mainLight.direction));
                half3 mainLightCol = mainLight.color * NdotLMain * mainLight.shadowAttenuation;

                half3 addLights = half3(0,0,0);
            #ifdef _ADDITIONAL_LIGHTS
                uint count = GetAdditionalLightsCount();
                for (uint i = 0; i < count; ++i)
                {
                    Light l = GetAdditionalLight(i, IN.positionWS);
                    half NdotL = saturate(dot(nWS, l.direction));
                    addLights += l.color * NdotL;
                }
            #endif

                half3 lighting = (bakedGI + mainLightCol + addLights) * ao;

                // --- Final Color & Fog ---
                half3 finalCol = baseCol.rgb * lighting;
                finalCol = MixFog(finalCol, IN.fogCoord);
                return half4(finalCol, baseCol.a);
            }
            ENDHLSL
        }
    }
}
