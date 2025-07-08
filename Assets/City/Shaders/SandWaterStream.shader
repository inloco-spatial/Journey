Shader "Custom/SandWaterStream"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Speed ("Fall Speed", Float) = 1
        _Distort ("Distortion Amount", Float) = 0.3
        _WidthTop ("Top Width Factor", Float) = 0.3
        _Alpha ("Alpha", Range(0,1)) = 1
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Speed;
            float _Distort;
            float _WidthTop;
            float _Alpha;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float worldY : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                float yFactor = saturate(v.vertex.y); // от 0 (низ) до 1 (верх)

                // Сужение к верху
                float width = lerp(1.0, _WidthTop, yFactor);
                v.vertex.x *= width;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldY = v.vertex.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Анимация падения
                uv.y += _Time.y * _Speed;

                // Легкое волнообразное искажение
                uv.x += sin(i.worldY * 10 + _Time.y * _Speed) * _Distort;

                fixed4 col = tex2D(_MainTex, uv) * _Color;
                col.a *= _Alpha;

                return col;
            }
            ENDCG
        }
    }
}
