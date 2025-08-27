Shader "Custom/SkyStar-Unlit-Wave-Reflect-Fog"
{
    Properties
    {
        _BaseMap            ("Base Texture", 2D)        = "white" {}
        _BaseColor          ("Tint Color", Color)       = (1,1,1,1)

        // Water ripple controls
        _WaveAmplitude      ("Wave Amplitude", Range(0,0.5))  = 0.05
        _WaveFrequency      ("Wave Frequency", Range(0.1,20))  = 2.0
        _WaveSpeed          ("Wave Speed", Range(0,5))        = 1.0

        // Fake Reflection
        _ReflectionMap      ("Reflection Cubemap", CUBE)      = "_Skybox" {}
        _ReflectionStrength ("Reflection Strength", Range(0,1)) = 0.5
        _FresnelPower       ("Fresnel Power", Range(0.1,5))   = 2.0

        // Fog parameters (linear)
        _FogColor           ("Fog Color", Color)             = (0.5,0.5,0.5,1)
        _FogStart           ("Fog Start Distance", Float)    = 0
        _FogEnd             ("Fog End Distance", Float)      = 50

        // Star controls
        _StarColor          ("Star Color", Color)           = (1,1,0.8,1)
        _StarDensity        ("Star Density", Range(0,1))    = 0.12
        _StarGlow           ("Star Glow", Range(0,50))      = 2
        _StarHashScale      ("Star Hash Scale", Range(10,500)) = 180
        _StarRadius         ("Star Radius (px)", Range(0.5,4)) = 1.5
        _StarSoftness       ("Star Softness", Range(0.5,6))  = 3
        _StarFlickerSpeed   ("Star Flicker Speed", Range(0,10))= 0
        _StarFlickerAmt     ("Star Flicker Amount", Range(0,1))= 0
        _StarBandAxis       ("Star Band Axis (World)", Vector)= (0,0,1,0)
        _StarBandOffset     ("Star Band Offset", Float)      = 0.0
        _StarBandSharpness  ("Star Band Sharpness", Range(0,20))= 0.0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200
        ZWrite On
        Blend One Zero

        Pass
        {
            Name "UnlitStarsWaveReflectFog"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _SINGLE_PASS_STEREO
            
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnityCG.cginc"

            sampler2D _BaseMap; 
            //SAMPLER(sampler_BaseMap);
            float4 _ReflectionMap; 
            //SAMPLER(sampler_ReflectionMap);

            float4 _BaseMap_ST;
            float4 _BaseColor;
            half _WaveAmplitude, _WaveFrequency, _WaveSpeed;
            half _ReflectionStrength, _FresnelPower;
            float4 _FogColor;
            float _FogStart, _FogEnd;
            float4 _StarColor;
            half _StarDensity, _StarGlow, _StarHashScale, _StarRadius, _StarSoftness;
            half _StarFlickerSpeed, _StarFlickerAmt;
            float4 _StarBandAxis;
            half _StarBandOffset, _StarBandSharpness;

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
                //UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float2 uv          : TEXCOORD1;
                float  viewDepth   : TEXCOORD2;
                //UNITY_VERTEX_OUTPUT_STEREO
                //UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                //UNITY_SETUP_INSTANCE_ID(IN);
                //UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                //float3 wsPos = TransformObjectToWorld(IN.positionOS.xyz);
                float3 wsPos = IN.positionOS.xyz;
                float t = _Time.y * _WaveSpeed;
                float wave = sin((wsPos.x + t) * _WaveFrequency) * cos((wsPos.z + t) * _WaveFrequency) * _WaveAmplitude;
                wsPos.y += wave;

                float2 ripple = float2(
                    sin((wsPos.x + t) * _WaveFrequency),
                    cos((wsPos.z + t) * _WaveFrequency)
                ) * _WaveAmplitude;

                OUT.positionHCS = TransformWorldToHClip(wsPos);
                OUT.positionWS = wsPos;
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap) + ripple;
                OUT.viewDepth = distance(_WorldSpaceCameraPos, wsPos);
                return OUT;
            }

            half starShapeSoft(half distPx)
            {
                half x = distPx / _StarRadius;
                return exp(-x * x * _StarSoftness);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                half3 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).rgb * _BaseColor.rgb;

                float3 viewDir = normalize(_WorldSpaceCameraPos - IN.positionWS);
                float fresnel = pow(1 - saturate(dot(viewDir, float3(0,1,0))), _FresnelPower);
                float3 reflDir = reflect(-viewDir, float3(0,1,0));
                half3 reflCol = SAMPLE_TEXTURECUBE(_ReflectionMap, sampler_ReflectionMap, reflDir).rgb;
                baseCol = lerp(baseCol, reflCol, _ReflectionStrength * fresnel);

                half2 cellPos   = IN.positionWS.xz * _StarHashScale;
                half2 cellCoord = floor(cellPos);
                half2 inCell    = frac(cellPos);
                half pick       = hash21(cellCoord);
                if (pick > 1.0h - _StarDensity)
                {
                    half2 center = half2(hash21(cellCoord + 101.7h), hash21(cellCoord + 47.3h));
                    half2 toStar = inCell - center;
                    half2 dx = ddx(IN.positionHCS.xy);
                    half2 dy = ddy(IN.positionHCS.xy);
                    half pixelSize = (abs(dx.x)+abs(dx.y)+abs(dy.x)+abs(dy.y)) * 0.25h;
                    half distPx = length(toStar) * _StarHashScale / max(pixelSize,1e-3h);
                    half shape = starShapeSoft(distPx);
                    if (shape > 0.001h)
                    {
                        half band = 1.0h;
                        if (_StarBandSharpness > 0.001h)
                        {
                            half d = abs(dot(IN.positionWS, _StarBandAxis.xyz) + _StarBandOffset);
                            band = exp(-d * _StarBandSharpness);
                        }
                        half flick = 1.0h;
                        if (_StarFlickerAmt > 0.001h)
                        {
                            half ph = hash21(cellCoord + 173.8h);
                            half tw = 0.5h + 0.5h * sin((_Time.y * _StarFlickerSpeed) + ph * 6.28318h);
                            flick = lerp(1.0h - _StarFlickerAmt, 1.0h, tw);
                        }
                        baseCol += _StarColor.rgb * shape * band * _StarGlow * flick;
                    }
                }

                // Apply linear fog
                float fogFactor = saturate((IN.viewDepth - _FogStart) / (_FogEnd - _FogStart));
                baseCol = lerp(baseCol, _FogColor.rgb, fogFactor);

                return half4(baseCol,1);
            }
            ENDHLSL
        }
    }
    FallBack "Unlit/Texture"
}
