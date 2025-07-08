Shader "Custom/OpaqueBaseFogEmission"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        _EmissionMap ("Emission Map", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _EmissionStrength ("Emission Strength", Range(0,8)) = 1.0

        _FogColor ("Fog Color", Color) = (0.5,0.5,0.5,1)
        _FogDensity ("Fog Density", Range(0,1)) = 0.1
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Cull Off
        Lighting Off
        ZWrite On
        Blend Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;

            sampler2D _EmissionMap;
            float4 _EmissionMap_ST;
            float4 _EmissionColor;
            float _EmissionStrength;

            float4 _FogColor;
            float _FogDensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos        : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 worldPos   : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Базовый цвет + текстура
                fixed4 baseCol = tex2D(_MainTex, i.uv) * _BaseColor;

                // Emission
                fixed4 emi = tex2D(_EmissionMap, i.uv) * _EmissionColor;
                baseCol.rgb += emi.rgb * _EmissionStrength;

                // Fog
                float dist = length(_WorldSpaceCameraPos - i.worldPos);
                float fogFactor = 1.0 - exp(-_FogDensity * _FogDensity * dist * dist);
                baseCol.rgb = lerp(baseCol.rgb, _FogColor.rgb, fogFactor);

                return baseCol;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
