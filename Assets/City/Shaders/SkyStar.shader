Shader "Custom/SkyStar-Unlit"
{
    Properties
    {
        _BaseMap   ("Base Texture", 2D)   = "white" {}
        _BaseColor ("Tint Color",  Color) = (1,1,1,1)

        // ✧ Star / glitter controls ---------------------------------------
        _StarColor        ("Star Color",          Color)        = (1,1,0.8,1)
        _StarDensity      ("Star Density",        Range(0,1))  = 0.12
        _StarGlow         ("Star Glow",           Range(0,50)) = 2
        _StarHashScale    ("Star Hash Scale",     Range(10,500)) = 180
        _StarRadius       ("Star Radius (px)",    Range(0.5,4)) = 1.5
        _StarSoftness     ("Star Softness",       Range(0.5,6)) = 3

        // set flicker to OFF by default; you can turn it up a bit
        _StarFlickerSpeed ("Star Flicker Speed",  Range(0,10)) = 0
        _StarFlickerAmt   ("Star Flicker Amount", Range(0,1))  = 0

        // optional band
        _StarBandAxis      ("Star Band Axis (World)", Vector) = (0,0,1,0)
        _StarBandOffset    ("Star Band Offset",      Float)   = 0.0
        _StarBandSharpness ("Star Band Sharpness",   Range(0,20)) = 0.0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200
        ZWrite On
        Blend One Zero

        Pass
        {
            Name "UnlitStars"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _SINGLE_PASS_STEREO

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _BaseColor;

            float4 _StarColor;
            half   _StarDensity;
            half   _StarGlow;
            half   _StarHashScale;
            half   _StarRadius;   // in pixels
            half   _StarSoftness; // exponential falloff control
            half   _StarFlickerSpeed;
            half   _StarFlickerAmt;
            float4 _StarBandAxis;
            half   _StarBandOffset;
            half   _StarBandSharpness;

            // hash util ------------------------------------------------------
            float hash21(float2 p)
            {
                p = frac(p * 0.3183099 + 0.1);
                p *= 17.0;
                return frac(p.x * p.y * (p.x + p.y));
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float2 uv          : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float3 wsPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformWorldToHClip(wsPos);
                OUT.positionWS = wsPos;
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half starShapeSoft(half distPx)
            {
                // gaussian-like softness: exp(- (dist/radius)^2 * softness)
                half x = distPx / _StarRadius;
                return exp(-x * x * _StarSoftness);
            }

            half4 frag (Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                half3 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).rgb * _BaseColor.rgb;

                // ----- star placement: world anchored, pixel radius ---------
                half2 cellPos = IN.positionWS.xz * _StarHashScale;
                half2 cellCoord = floor(cellPos);
                half2 inCell = frac(cellPos);

                half pick = hash21(cellCoord);
                if (pick <= 1.0h - _StarDensity) return half4(baseCol,1);

                half2 starCenter = half2(hash21(cellCoord + 101.7h), hash21(cellCoord + 47.3h));
                half2 uvToStar = (inCell - starCenter);

                // convert to pixel space via screen-space derivatives
                half2 dx = ddx(IN.positionHCS.xy);
                half2 dy = ddy(IN.positionHCS.xy);
                half2 worldToClip = abs(dx) + abs(dy);
                half pixelSize = (worldToClip.x + worldToClip.y) * 0.5h;
                // dist in pixels
                half distPx = length(uvToStar) * _StarHashScale / max(pixelSize, 1e-3h);

                half starShape = starShapeSoft(distPx);
                if (starShape <= 0.001h) return half4(baseCol,1);

                // band mask optional
                half bandMask = 1.0h;
                if (_StarBandSharpness > 0.001h)
                {
                    half d = abs(dot(IN.positionWS, _StarBandAxis.xyz) + _StarBandOffset);
                    bandMask = exp(-d * _StarBandSharpness);
                }

                // minimal or zero flicker
                half flicker = 1.0h;
                if (_StarFlickerAmt > 0.001h)
                {
                    half phase = hash21(cellCoord + 173.8h);
                    half tw = 0.5h + 0.5h * sin((_Time.y * _StarFlickerSpeed) + phase * 6.28318h);
                    flicker = lerp(1.0h - _StarFlickerAmt, 1.0h, tw);
                }

                half sprayInt = starShape * bandMask * _StarGlow * flicker;
                half3 finalCol = baseCol + _StarColor.rgb * sprayInt;
                return half4(finalCol,1);
            }
            ENDHLSL
        }
    }

    FallBack "Unlit/Texture"
}
