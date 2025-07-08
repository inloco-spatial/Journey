Shader "Custom/ChintzTentURP_UnlitWithTint_Fog"
{
    Properties
    {
        // — Albedo & Opacity —
        _MainTex        ("Albedo (RGB) + Opacity (A)", 2D)   = "white" {}
        _NormalMap      ("Normal Map",                   2D)   = "bump"  {}
        _AlphaMap       ("Opacity Mask (R)",             2D)   = "white" {}
        _LightMap       ("Custom Light Map",             2D)   = "white" {}
        _TintColor      ("Albedo Tint",                  Color)= (1,1,1,1)
        _LightPower     ("Light Softness (Power)",       Range(0.1,8)) = 2.0
        _Cutoff         ("Alpha Cutoff",                 Range(0,1))   = 0.1

        // — Wind —
        _WindSpeed      ("Wind Speed",                   Float) = 1.0
        _WindAmplitude  ("Wind Amplitude",               Float) = 0.1
        _LeftWindWidth  ("Left Edge Width",      Range(0,0.5)) = 0.2
        _RightWindWidth ("Right Edge Width",     Range(0,0.5)) = 0.2
        _BottomHeight   ("Bottom Height",       Range(0,1))   = 0.2

        // — Lighting —
        _LightDir       ("Light Direction",              Vector)= (0,1,1,0)
        _LightColor     ("Light Color",                  Color)= (1,1,1,1)
        _AmbientColor   ("Ambient Color",                Color)= (0.2,0.2,0.2,1)

        // — Fake Fog —
        _FogColor       ("Fog Color",                    Color)= (0.5,0.5,0.5,1)
        _FogStart       ("Fog Start Distance",           Float)= 10.0
        _FogEnd         ("Fog End Distance",             Float)= 50.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "Pipeline"="UniversalPipeline" }
        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        // Общие include-блоки и функции
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #define PI 3.14159265359

        TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);      SAMPLER(sampler_NormalMap);
        TEXTURE2D(_AlphaMap);       SAMPLER(sampler_AlphaMap);
        TEXTURE2D(_LightMap);       SAMPLER(sampler_LightMap);

        float4 _TintColor;
        float _LightPower;
        float _Cutoff;
        float _WindSpeed, _WindAmplitude, _LeftWindWidth, _RightWindWidth, _BottomHeight;
        float4 _LightDir;
        float4 _LightColor;
        float4 _AmbientColor;

        // Параметры «фейкового» тумана
        float4 _FogColor;
        float  _FogStart;
        float  _FogEnd;

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS   : NORMAL;
            float4 tangentOS  : TANGENT;
            float2 uv         : TEXCOORD0;
        };

        struct Varyings
        {
            float4 positionH   : SV_POSITION;
            float2 uv          : TEXCOORD0;
            float3 normalWS    : TEXCOORD1;
            float3 tangentWS   : TEXCOORD2;
            float3 bitangentWS : TEXCOORD3;
            float3 posWS       : TEXCOORD4; // мир. позиция для тумана
        };

        Varyings vert(Attributes IN)
        {
            Varyings OUT;

            // — Wind effect with smooth edges —
            float3 pos = IN.positionOS;
            float2 uv  = IN.uv;
            if (uv.y < _BottomHeight)
            {
                float falloff   = 1 - saturate(uv.y / _BottomHeight);
                float wave      = sin(uv.x * PI + _Time.y * _WindSpeed);
                float leftMask  = smoothstep(_LeftWindWidth, 0.0, uv.x);
                float rightMask = smoothstep(1.0 - _RightWindWidth, 1.0, uv.x);
                float edgeMask  = saturate(leftMask + rightMask);
                pos.x += wave * _WindAmplitude * falloff * edgeMask;
            }

            // — Transform to world & clip —
            OUT.posWS      = TransformObjectToWorld(pos);
            OUT.positionH  = TransformObjectToHClip(pos);
            OUT.normalWS   = TransformObjectToWorldNormal(IN.normalOS);
            OUT.tangentWS  = TransformObjectToWorldDir(IN.tangentOS.xyz);
            OUT.bitangentWS= cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;
            OUT.uv         = uv;

            return OUT;
        }

        half4 frag(Varyings IN) : SV_Target
        {
            // — Base color, tint, alpha & cutoff —
            float4 baseRGBA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
            baseRGBA.rgb   *= _TintColor.rgb;
            float maskA     = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, IN.uv).r;
            float alpha     = baseRGBA.a * maskA;
            clip(alpha - _Cutoff);

            // — Normal mapping (TBN) —
            float3 nTS = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv).xyz * 2 - 1;
            float3 N = normalize(
                  nTS.x * IN.tangentWS
                + nTS.y * IN.bitangentWS
                + nTS.z * IN.normalWS
            );

            // — Fake Lambert + softness —
            float3 Ldir   = normalize(_LightDir.xyz);
            float  NdotL  = saturate(dot(N, Ldir));
            float  soft   = pow(NdotL, _LightPower);
            float3 lambert= _AmbientColor.rgb + _LightColor.rgb * soft;

            // — Custom lightmap modulation —
            float3 customLM = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, IN.uv).rgb;
            float3 colLit   = baseRGBA.rgb * lambert * customLM;

            // — Fake Fog —
            // глобальная _WorldSpaceCameraPos уже объявлена в Core.hlsl
            float  dist   = distance(IN.posWS, _WorldSpaceCameraPos);
            float  fogF   = saturate((dist - _FogStart) / (_FogEnd - _FogStart));
            float3 finalC = lerp(colLit, _FogColor.rgb, fogF);

            return float4(finalC, alpha);
        }
        ENDHLSL

        // Второй проход для URP
        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"
}
