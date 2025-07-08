Shader "Custom/RealisticWindRibbon_V2"
{
    Properties
    {
        _BaseMap ("Albedo (RGB)", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        _EmissionMap ("Emission Map", 2D) = "black" {}
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _EmissionStrength ("Emission Strength", Range(0,10)) = 1.0

        _WindStrength ("Wind Strength", Range(0, 20)) = 5
        _WindSpeed ("Wind Speed", Range(0, 10)) = 2
        _WindFrequency ("Base Frequency", Range(0.1, 5)) = 1
        _SecondaryWave ("Secondary Wave Strength", Range(0, 5)) = 1
        _TwistAmount ("Twist Amount", Range(0, 5)) = 1
        _BendAmount ("Global Bend Amount", Range(0, 5)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            Cull Off // Делаем двухсторонний материал

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _BaseMap;
            sampler2D _EmissionMap;
            float4 _BaseColor;
            float4 _EmissionColor;
            float _EmissionStrength;

            float _WindStrength;
            float _WindSpeed;
            float _WindFrequency;
            float _SecondaryWave;
            float _TwistAmount;
            float _BendAmount;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 pos = IN.positionOS.xyz;
                float time = _Time.y * _WindSpeed;

                float height01 = saturate(pos.y); // Нормализованная высота (0 - основание, 1 - кончик)

                // --- Основная большая волна ---
                float primaryWave = sin(pos.y * _WindFrequency + time) * _WindStrength;

                // --- Дополнительная мелкая волна ---
                float secondaryWave = sin(pos.y * (_WindFrequency * 2.5) + time * 1.7) * _SecondaryWave;

                // --- Суммарный ветер с затухающей амплитудой к основанию ---
                float totalWaveX = (primaryWave + secondaryWave) * height01;

                // --- Дополнительная нестабильность через сложный синус ---
                float turbulence = sin(time * 2.0 + pos.y * 3.0) * 0.3 * height01;
                totalWaveX += turbulence;

                float totalWaveZ = cos(pos.y * (_WindFrequency * 0.7) + time * 1.5) * (_WindStrength * 0.5) * height01;

                // --- Лёгкий глобальный прогиб всей ленты ---
                float globalBend = _BendAmount * height01 * sin(time * 0.3);

                pos.x += totalWaveX + globalBend;
                pos.z += totalWaveZ;

                // --- Скручивание вдоль высоты ---
                float twist = (pos.y + time * 0.2) * _TwistAmount;
                float cosTwist = cos(twist);
                float sinTwist = sin(twist);

                float3 twistedPos;
                twistedPos.x = pos.x * cosTwist - pos.z * sinTwist;
                twistedPos.y = pos.y;
                twistedPos.z = pos.x * sinTwist + pos.z * cosTwist;

                OUT.positionHCS = TransformObjectToHClip(twistedPos);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 baseTex = tex2D(_BaseMap, IN.uv) * _BaseColor;
                half4 emissionTex = tex2D(_EmissionMap, IN.uv) * _EmissionColor * _EmissionStrength;
                return baseTex + emissionTex;
            }
            ENDHLSL
        }
    }
}
