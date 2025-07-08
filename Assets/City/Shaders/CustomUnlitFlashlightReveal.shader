Shader "Custom/UnlitFlashlightReveal_PulseGlow_Noise"
{
    Properties
    {
        _MainTex           ("AlphaMask",            2D)    = "white" {}
        _NoiseTex          ("NoiseTex",             2D)    = "white" {}
        _NoiseScale        ("NoiseScale",           Float)= 10
        _NoiseStrength     ("NoiseStrength",        Range(0,0.5)) = 0.05
        _BaseColor         ("BaseColor",            Color)= (1,1,1,1)
        _GlowColor         ("GlowColor",            Color)= (1,1,0.5,1)
        _EdgeWidth         ("EdgeWidth",            Range(0.001,1)) = 0.02
        _BaseGlowIntensity ("BaseGlowIntensity",    Range(0,10)) = 1.5
        _GlowIntensity     ("GlowIntensity",        Range(0,20)) = 6
        _Radius            ("Radius",               Range(0,1)) = 0
        _HeartbeatRate     ("HeartbeatRate",        Float)= 60
        _PulseAmount       ("PulseAmount",          Range(0,2)) = 1
        _LightPos          ("LightPos (UV)",        Vector)= (0.5,0.5,0,0)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4   _MainTex_ST;
            sampler2D _NoiseTex;
            float    _NoiseScale;
            float    _NoiseStrength;
            float4   _BaseColor;
            float4   _GlowColor;
            float    _EdgeWidth;
            float    _BaseGlowIntensity;
            float    _GlowIntensity;
            float    _Radius;
            float4   _LightPos;
            float    _HeartbeatRate;
            float    _PulseAmount;

            struct appdata { float4 vertex:POSITION; float2 uv:TEXCOORD0; };
            struct v2f     { float4 pos:SV_POSITION; float2 uv: TEXCOORD0; };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // базовая маска
                float alphaMask = tex2D(_MainTex, i.uv).r;
                // расстояние до центра «фонарика»
                float dist = distance(i.uv, _LightPos.xy);

                // неровный край через шум
                float noise = tex2D(_NoiseTex, i.uv * _NoiseScale + _Time.y * 0.1).r;
                float noisyDist = dist + (noise - 0.5) * _NoiseStrength;

                // проявление
                float reveal = smoothstep(_Radius, _Radius - _EdgeWidth, noisyDist);
                float baseAlpha = reveal * alphaMask;

                // крайнее свечение
                float edge = smoothstep(_Radius - _EdgeWidth, _Radius, noisyDist)
                           - smoothstep(_Radius, _Radius + _EdgeWidth, noisyDist);

                // пульсация сердца
                float pulse = abs(sin(_Time.y * (_HeartbeatRate / 60) * 6.2831853));
                pulse = lerp(1.0, pulse, _PulseAmount);

                // соберём свечение: шумной гранью + равномерным по всей маске
                float3 edgeGlow = _GlowColor.rgb * edge * _GlowIntensity * pulse;
                float3 baseGlow = _GlowColor.rgb * alphaMask * _BaseGlowIntensity * pulse;

                // итоговый цвет
                float3 col = _BaseColor.rgb * baseAlpha;
                float3 glow = edgeGlow + baseGlow;

                return float4(col + glow, baseAlpha);
            }
            ENDCG
        }
    }
}
