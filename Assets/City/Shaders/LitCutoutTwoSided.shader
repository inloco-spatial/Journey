Shader "Custom/URP/LitCutoutTwoSided"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _AlphaMap("Alpha Mask (B/W)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _OcclusionMap("Ambient Occlusion Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
        _FogColor("Fog Color", Color) = (0.5,0.5,0.5,1)
        _FogStart("Fog Start Distance", Float) = 0
        _FogEnd("Fog End Distance", Float) = 50
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        Cull Off

        // Shadow caster pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            HLSLPROGRAM
            #pragma vertex VertShadow
            #pragma fragment FragShadow
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct AttributesShadow { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
            struct VaryingsShadow { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };
            sampler2D _AlphaMap;
            float _Cutoff;

            VaryingsShadow VertShadow(AttributesShadow IN)
            {
                VaryingsShadow OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            float FragShadow(VaryingsShadow IN) : SV_Target
            {
                float alphaMask = tex2D(_AlphaMap, IN.uv).r;
                clip(alphaMask - _Cutoff);
                return 0;
            }
            ENDHLSL
        }

        // Main forward-lit pass with normal mapping, AO and manual fog support
        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            #pragma vertex VertMain
            #pragma fragment FragMain
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct AttributesMain
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
            };
            struct VaryingsMain
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float3 tangentWS  : TEXCOORD2;
                float3 bitangentWS: TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float  viewDist   : TEXCOORD5;
            };

            sampler2D _BaseMap;
            sampler2D _AlphaMap;
            sampler2D _NormalMap;
            sampler2D _OcclusionMap;
            float4 _BaseColor;
            float _Cutoff;
            float4 _FogColor;
            float _FogStart;
            float _FogEnd;

            VaryingsMain VertMain(AttributesMain IN)
            {
                VaryingsMain OUT;
                // World space
                float3 worldPos = TransformObjectToWorld(IN.positionOS).xyz;
                OUT.positionWS = worldPos;
                OUT.positionCS = TransformWorldToHClip(worldPos);
                OUT.uv = IN.uv;
                // TBN
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));
                OUT.bitangentWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;
                // View distance for fog
                OUT.viewDist = distance(_WorldSpaceCameraPos, worldPos);
                return OUT;
            }

            half4 FragMain(VaryingsMain IN) : SV_Target
            {
                // Color and alpha mask
                half4 baseCol = tex2D(_BaseMap, IN.uv) * _BaseColor;
                half alphaMask = tex2D(_AlphaMap, IN.uv).r;
                clip(alphaMask - _Cutoff);

                // Normal mapping
                half3 nmap = tex2D(_NormalMap, IN.uv).rgb * 2 - 1;
                float3 normalWS = normalize(
                    nmap.x * IN.tangentWS +
                    nmap.y * IN.bitangentWS +
                    nmap.z * IN.normalWS);

                // Ambient occlusion
                half ao = tex2D(_OcclusionMap, IN.uv).r;

                // Simple Lambert lighting
                float3 lightDir = normalize(_MainLightPosition.xyz);
                half diff = max(dot(normalWS, lightDir), 0);
                half3 lightCol = _MainLightColor.rgb;
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * ao;
                half3 color = baseCol.rgb * (lightCol * diff + ambient);
                half4 outCol = half4(color, alphaMask);

                // Manual linear fog
                float fogFactor = saturate((IN.viewDist - _FogStart) / (_FogEnd - _FogStart));
                outCol.rgb = lerp(outCol.rgb, _FogColor.rgb, fogFactor);
                return outCol;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/Unlit"
}