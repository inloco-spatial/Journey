Shader "Custom/LitSimple_Wind_Fog_Emission"
{
    Properties
    {
        //--- Base ---
        _BaseMap       ("Base Map",              2D)    = "white" {}
        _BaseColor     ("Base Color",            Color) = (1,1,1,1)
        _BumpMap       ("Normal Map",            2D)    = "bump"  {}
        _NormalStrength("Normal Strength",       Range(0,2)) = 1.0
        _AOMap         ("AO Map (B&W)",          2D)    = "white" {}
        _AOStrength    ("AO Strength",           Range(0,1)) = 0.5

        //--- Wind ---
        _WindDirection ("Wind Direction",        Vector) = (1,0,0,0)
        _WindStrength  ("Wind Strength",         Range(0,1)) = 0.2
        _WindFrequency ("Wind Frequency",        Range(0,10)) = 1.0
        _WindSpeed     ("Wind Speed",            Range(0,10)) = 1.0

        //--- Cutout ---
        _CutoutMap     ("Cutout Map (B&W)",      2D)    = "white" {}
        _Cutoff        ("Alpha Cutoff",          Range(0,1)) = 0.5

        //--- Fake Fog ---
        _FogColor      ("Fog Color",             Color) = (0.5,0.5,0.5,1)
        _FogStart      ("Fog Start Distance",    Float) = 10
        _FogEnd        ("Fog End Distance",      Float) = 50

        //--- Emission ---
        _EmissionMap      ("Emission Map (B&W)",    2D)    = "white" {}
        _EmissionColor    ("Emission Tint",         Color) = (1,1,1,1)
        _EmissionStrength ("Emission Strength",     Range(0,10)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 300
        Cull Off

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Самплеры
            TEXTURE2D(_BaseMap);       SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);       SAMPLER(sampler_BumpMap);
            TEXTURE2D(_AOMap);         SAMPLER(sampler_AOMap);
            TEXTURE2D(_CutoutMap);     SAMPLER(sampler_CutoutMap);
            TEXTURE2D(_EmissionMap);   SAMPLER(sampler_EmissionMap);

            // Материальные параметры
            float4 _BaseColor;
            float _NormalStrength;
            float _AOStrength;

            // Ветер
            float4 _WindDirection;
            float  _WindStrength;
            float  _WindFrequency;
            float  _WindSpeed;

            // Cutout
            float _Cutoff;

            // Fake Fog
            float4 _FogColor;
            float _FogStart;
            float _FogEnd;

            // Emission
            float4 _EmissionColor;
            float _EmissionStrength;

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
                float3 normalWS    : TEXCOORD1;
                float3 tangentWS   : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv          : TEXCOORD4;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                // Wind
                float falloff = IN.uv.y;
                float wave1 = sin(dot(IN.positionOS.xz, _WindDirection.xz) * _WindFrequency + _Time.y * _WindSpeed);
                float wave2 = sin((IN.positionOS.x + IN.positionOS.z) * _WindFrequency * 1.3 + _Time.y * _WindSpeed * 1.7);
                float totalWind = lerp(0, (wave1 + wave2) * 0.5 * _WindStrength, falloff);
                float3 newPosOS = IN.positionOS.xyz + _WindDirection.xyz * totalWind;

                OUT.positionHCS = TransformObjectToHClip(newPosOS);
                OUT.positionWS  = TransformObjectToWorld(newPosOS);

                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                OUT.tangentWS   = TransformObjectToWorldDir(IN.tangentOS.xyz);
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Cutout
                half alphaCut = SAMPLE_TEXTURE2D(_CutoutMap, sampler_CutoutMap, IN.uv).r;
                clip(alphaCut - _Cutoff);

                // Base + AO
                half4 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                half ao = SAMPLE_TEXTURE2D(_AOMap, sampler_AOMap, IN.uv).r;
                ao = lerp(1.0, ao, _AOStrength);

                // Normal
                half3 nTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv));
                nTS.xy *= _NormalStrength;
                nTS = normalize(nTS);
                float3x3 TBN = float3x3(
                    normalize(IN.tangentWS),
                    normalize(IN.bitangentWS),
                    normalize(IN.normalWS)
                );
                half3 nWS = normalize(mul(nTS, TBN));

                // Lighting
                InputData data = (InputData)0;
                data.positionWS      = IN.positionWS;
                data.normalWS        = nWS;
                data.viewDirectionWS = GetWorldSpaceViewDir(IN.positionWS);
                data.shadowCoord     = TransformWorldToShadowCoord(IN.positionWS);

                half3 gi = SampleSH(nWS);
                Light mainL = GetMainLight(data.shadowCoord);
                half nl = saturate(dot(nWS, mainL.direction));
                half3 colMain = mainL.color * nl * mainL.shadowAttenuation;

                half3 add = half3(0,0,0);
            #ifdef _ADDITIONAL_LIGHTS
                for (uint i=0; i < GetAdditionalLightsCount(); ++i)
                {
                    Light l = GetAdditionalLight(i, IN.positionWS);
                    half d = saturate(dot(nWS, l.direction));
                    add += l.color * d;
                }
            #endif

                half3 lit = (gi + colMain + add) * ao;
                half3 colorLit = baseCol.rgb * lit;

                // Emission
                half eMask = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, IN.uv).r;
                half3 emission = eMask * _EmissionStrength * _EmissionColor.rgb;
                half3 withEmission = colorLit + emission;

                // Fake Fog (используем глобальную _WorldSpaceCameraPos)
                float dist = distance(IN.positionWS, _WorldSpaceCameraPos);
                float fogF = saturate((dist - _FogStart) / (_FogEnd - _FogStart));
                half3 final = lerp(withEmission, _FogColor.rgb, fogF);

                return half4(final, baseCol.a);
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
