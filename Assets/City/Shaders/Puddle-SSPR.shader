Shader "Custom/SpatialPuddle-SSPR-ScreenFlip"
{
    Properties
    {
        _BaseMap           ("Base Texture",              2D)    = "white" {}
        _BaseColor         ("Tint Color",                Color) = (1,1,1,1)
        _BaseMap_ST        ("Base Tiling/Offset",        Vector)= (1,1,0,0)

        _MaskTex           ("Cutout Mask (B&W)",         2D)    = "white" {}
        _MaskThreshold     ("Mask Threshold",   Range(0,1))    = 0.5
        _MaskFeather       ("Mask Feather",     Range(0,0.5))    = 0.1
        _MaskTex_ST        ("Mask Tiling/Offset",        Vector)= (1,1,0,0)

        _WaveAmplitude     ("Wave Amplitude",  Range(0,0.5))    = 0.05
        _WaveFrequency     ("Wave Frequency",  Range(0.1,20))    = 2.0
        _WaveSpeed         ("Wave Speed",      Range(0,5))      = 1.0

        _ReflectAmt        ("Reflection Strength", Range(0,1))  = 0.5
        _ReflBlurSize      ("Reflection Blur Size", Range(0,0.05)) = 0.01
        _FresnelPower      ("Fresnel Power",     Range(0.1,5))   = 2.0

        _PlaneY            ("Puddle Height (Y)",        Float) = 6.51
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="Transparent" }
        LOD 200

        Cull Off
        ZWrite On
        ZTest LEqual
        Blend One Zero

        Pass
        {
            Name "SSPR_ScreenFlip"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _REQUIRE_OPAQUETEXTURE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Textures & samplers
            TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MaskTex);               SAMPLER(sampler_MaskTex);
            TEXTURE2D(_CameraOpaqueTexture);   SAMPLER(sampler_CameraOpaqueTexture);

            // Uniforms
            float4 _BaseMap_ST;
            float4 _BaseColor;
            float4 _MaskTex_ST;
            half   _MaskThreshold, _MaskFeather;
            half   _WaveAmplitude, _WaveFrequency, _WaveSpeed;
            half   _ReflectAmt, _ReflBlurSize, _FresnelPower;
            float  _PlaneY;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos    : TEXCOORD0;
                float2 uvBase      : TEXCOORD1;
                float2 uvMask      : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                // World position + simple wave
                float3 ws = TransformObjectToWorld(IN.positionOS.xyz);
                float t = _Time.y * _WaveSpeed;
                ws.y += sin((ws.x + t) * _WaveFrequency) * _WaveAmplitude
                     + cos((ws.z + t) * _WaveFrequency) * _WaveAmplitude;

                OUT.positionHCS = TransformWorldToHClip(ws);
                OUT.worldPos    = ws;
                OUT.uvBase      = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.uvMask      = TRANSFORM_TEX(IN.uv, _MaskTex);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                // 1) Cutout mask
                half mVal   = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, IN.uvMask).r;
                half aMask  = smoothstep(_MaskThreshold - _MaskFeather,
                                         _MaskThreshold + _MaskFeather,
                                         mVal);
                clip(aMask - 0.01);

                // 2) Base water color
                half3 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uvBase).rgb 
                               * _BaseColor.rgb;

                // 3) Compute each pixel’s mirror relative to plane y = _PlaneY
                float3 mirroredWS = float3(
                    IN.worldPos.x,
                    2 * _PlaneY - IN.worldPos.y,
                    IN.worldPos.z
                );
                float4 clipPos = TransformWorldToHClip(mirroredWS);

                // 4) Convert to UV and flip vertically around plane center line
                float2 reflUV = clipPos.xy / clipPos.w * 0.5 + float2(0.5, 0.5);
                reflUV.y = 1 - reflUV.y;

                // 5) 4-tap box blur
                half3 sum = half3(0,0,0);
                sum += SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, reflUV + float2(-_ReflBlurSize, -_ReflBlurSize));
                sum += SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, reflUV + float2(-_ReflBlurSize,  _ReflBlurSize));
                sum += SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, reflUV + float2( _ReflBlurSize, -_ReflBlurSize));
                sum += SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, reflUV + float2( _ReflBlurSize,  _ReflBlurSize));
                half3 reflCol = sum * 0.25;

                // 6) Fresnel mix
                float3 viewDir = normalize(_WorldSpaceCameraPos - IN.worldPos);
                float f = pow(1 - saturate(dot(viewDir, float3(0,1,0))), _FresnelPower);
                baseCol = lerp(baseCol, reflCol, _ReflectAmt * f);

                return half4(baseCol, aMask);
            }
            ENDHLSL
        }
    }
    FallBack "Unlit/Texture"
}
