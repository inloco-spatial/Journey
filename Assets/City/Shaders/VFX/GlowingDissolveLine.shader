Shader "Custom/GlowingDissolveLine"
{
    Properties
    {
        _MainColor               ("Glow Color", Color)               = (1,0.8,0.2,1)
        _NoiseTex                ("Noise Texture", 2D)               = "white" {}
        _GlobalFade              ("Global Fade", Range(0,1))         = 1    // общий фейд всей линии
        _DissolveAmount          ("Dissolve Amount", Range(0,1))     = 0
        _InvertDissolve          ("Invert Dissolve", Float)          = 1    // перевёрнутый дизолв
        _DissolveWidth           ("Dissolve Softness", Range(0.001,0.5)) = 0.1
        _NoiseScale              ("Noise Scale", Float)              = 1
        _PulseSpeed              ("Pulse Speed", Float)              = 1
        _PulseStrength           ("Pulse Strength", Float)           = 0.2
        _JitterStrength          ("Jitter Strength", Float)          = 0.01
        _JitterRange             ("Jitter Range", Range(0,1))         = 1
        _JitterSpeed             ("Jitter Speed (Lower = Slower)", Range(0.001,1)) = 0.01
        _JitterSegmentScale      ("Jitter Segment Scale", Float)      = 20
        _OffsetAxes              ("Offset Axes (XYZ)", Vector)        = (0,1,0,0)
        _NoiseSpeed              ("Noise Animation Speed", Float)     = 1
        _WindStrength            ("Wind Strength", Float)             = 0.05
        _VertexOffsetScale       ("Vertex Offset Scale", Float)       = 1
        _GlowIntensity           ("Glow Intensity", Float)            = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend One One
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _NoiseTex;
            float4   _MainColor;
            float    _GlobalFade;
            float    _DissolveAmount;
            float    _InvertDissolve;
            float    _DissolveWidth;
            float    _NoiseScale;
            float    _PulseSpeed;
            float    _PulseStrength;
            float    _JitterStrength;
            float    _JitterRange;
            float    _JitterSpeed;
            float    _JitterSegmentScale;
            float4   _OffsetAxes;
            float    _NoiseSpeed;
            float    _WindStrength;
            float    _VertexOffsetScale;
            float    _GlowIntensity;

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float2 uv : TEXCOORD0; float4 pos : SV_POSITION; float noiseUV : TEXCOORD1; };

            // Псевдошум для секментного jitter
            float hash21(float2 p)
            {
                p = frac(p * float2(127.1, 311.7));
                p += dot(p, p + 34.345);
                return frac(sin(p.x + p.y) * 43758.5453123);
            }

            v2f vert(appdata v)
            {
                v2f o;
                float3 pos = v.vertex.xyz;

                // Временные параметры
                float tJit   = _Time.y * _JitterSpeed;
                float tNoise = _Time.y * _NoiseSpeed;

                // Сегментация UV для стабильного jitter
                float2 cell = floor(v.uv * _JitterSegmentScale) / _JitterSegmentScale;
                float seed  = hash21(cell);

                // Плавный синусоидальный jitter
                float jit = sin(seed * 6.283185 + tJit) * _JitterStrength * _JitterRange;
                // Ветровой эффект
                float wind = (v.uv.x - 0.5) * sin(tNoise + cell.x * 10) * _WindStrength;

                // Сборка вектора смещения
                float3 baseOff  = float3(jit + wind, jit + wind, jit + wind) * _VertexOffsetScale;
                float3 offsetV  = baseOff * _OffsetAxes.xyz;
                pos += offsetV;

                o.pos     = UnityObjectToClipPos(float4(pos, 1));
                o.uv      = v.uv;
                o.noiseUV = v.uv.y * _NoiseScale + tNoise;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Шум для свечения
                float n = tex2D(_NoiseTex, float2(i.noiseUV, i.uv.x * _NoiseScale)).r;

                // Инвертированный дизолв: появление снизу-вверх
                float d    = saturate(_DissolveAmount);
                float w    = max(0.0001, _DissolveWidth);
                float mask = smoothstep(d - w * 0.5, d + w * 0.5, 1 - i.uv.y);
                if (_InvertDissolve < 0.5) mask = 1 - mask;

                // Применяем глобальный фейд
                mask *= _GlobalFade;

                // Клиппинг
                clip(mask - 0.01);

                // Пульсация свечения
                float pulse = 1 + sin(_Time.y * _PulseSpeed + n * 6.283185) * _PulseStrength;
                float glow  = saturate(n * pulse) * _GlowIntensity * _GlobalFade;

                return float4(_MainColor.rgb * glow * mask, glow * mask);
            }
            ENDCG
        }
    }
}
