Shader "Custom/EmissiveFireNoise"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseSpeed ("Noise Speed", Float) = 1.0
        _NoiseScale ("Noise Scale", Float) = 1.0
        _EmissionColor ("Emission Color", Color) = (1, 0.5, 0.0, 1)
        _EmissionStrength ("Emission Strength", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _BaseColor;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _NoiseSpeed;
            float _NoiseScale;
            float4 _EmissionColor;
            float _EmissionStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time.y * _NoiseSpeed;
                float2 noiseUV = i.uv * _NoiseScale + float2(time, time);

                fixed noiseSample = tex2D(_NoiseTex, noiseUV).r;

                fixed4 baseColor = _BaseColor;

                fixed4 emissive = _EmissionColor * noiseSample * _EmissionStrength;

                fixed4 finalColor = baseColor + emissive;
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
