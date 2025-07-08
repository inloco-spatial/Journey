Shader "Custom/TerrainSimpleFog_OculusSpatial"
{
    Properties
    {
        _MainTex("Base Texture", 2D) = "white" {}
        _FogColor("Fog Color", Color) = (0.6, 0.6, 0.65, 1)
        _FogIntensity("Fog Intensity", Range(0, 1)) = 0.8
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _NoiseScale("Noise Scale", Range(0.01, 10)) = 1.0
        _NoiseSpeed("Noise Speed", Float) = 0.1
        _HeightStart("Fog Start Height", Float) = 0.0
        _HeightEnd("Fog End Height", Float) = 5.0
        _PerspectiveFogColor("Perspective Fog Tint", Color) = (0.4, 0.45, 0.5, 1)
        _PerspectiveFogStart("Perspective Start", Float) = 10.0
        _PerspectiveFogEnd("Perspective End", Float) = 100.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 200
        ZWrite On
        Cull Off

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float4 _FogColor;
            float4 _PerspectiveFogColor;
            float _FogIntensity;
            float _NoiseScale;
            float _NoiseSpeed;
            float _HeightStart;
            float _HeightEnd;
            float _PerspectiveFogStart;
            float _PerspectiveFogEnd;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.worldPos = worldPos;
                OUT.viewDir = _WorldSpaceCameraPos - worldPos;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 baseColor = tex2D(_MainTex, IN.uv).rgb;

                float2 animatedUV = IN.worldPos.xz * _NoiseScale + float2(_Time.y * _NoiseSpeed, _Time.y * -_NoiseSpeed);
                float noise = tex2D(_NoiseTex, animatedUV).r;

                float heightFactor = saturate((IN.worldPos.y - _HeightStart) / (_HeightEnd - _HeightStart));
                float fogFactor = saturate(noise * _FogIntensity * heightFactor);
                float3 foggedColor = lerp(baseColor, _FogColor.rgb, fogFactor);

                float dist = length(IN.viewDir);
                float depthShift = saturate((dist - _PerspectiveFogStart) / (_PerspectiveFogEnd - _PerspectiveFogStart));

                foggedColor *= lerp(1.0, 0.85, depthShift); // контрастность вниз
                float3 tintShift = float3(0.1, 0.2, 0.3); // лёгкий голубой оттенок
                foggedColor = lerp(foggedColor, foggedColor + tintShift, depthShift * 0.5);

                return float4(foggedColor, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
