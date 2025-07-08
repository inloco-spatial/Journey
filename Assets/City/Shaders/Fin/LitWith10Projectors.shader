Shader "Custom/LitWith10Projectors_CleanFinal_LitSimple"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _BumpMap ("Normal Map", 2D) = "bump" {}

        _MainTex0 ("Projection Texture 0", 2D) = "white" {}
        _Color0 ("Projection Color 0", Color) = (1,1,1,1)
        _Falloff0 ("Falloff 0", Range(0.01, 1)) = 0.5
        _EmissionStrength0 ("Emission Strength 0", Float) = 1.0

        _MainTex1 ("Projection Texture 1", 2D) = "white" {}
        _Color1 ("Projection Color 1", Color) = (1,1,1,1)
        _Falloff1 ("Falloff 1", Range(0.01, 1)) = 0.5
        _EmissionStrength1 ("Emission Strength 1", Float) = 1.0

        _MainTex2 ("Projection Texture 2", 2D) = "white" {}
        _Color2 ("Projection Color 2", Color) = (1,1,1,1)
        _Falloff2 ("Falloff 2", Range(0.01, 1)) = 0.5
        _EmissionStrength2 ("Emission Strength 2", Float) = 1.0

        _MainTex3 ("Projection Texture 3", 2D) = "white" {}
        _Color3 ("Projection Color 3", Color) = (1,1,1,1)
        _Falloff3 ("Falloff 3", Range(0.01, 1)) = 0.5
        _EmissionStrength3 ("Emission Strength 3", Float) = 1.0

        _MainTex4 ("Projection Texture 4", 2D) = "white" {}
        _Color4 ("Projection Color 4", Color) = (1,1,1,1)
        _Falloff4 ("Falloff 4", Range(0.01, 1)) = 0.5
        _EmissionStrength4 ("Emission Strength 4", Float) = 1.0

        _MainTex5 ("Projection Texture 5", 2D) = "white" {}
        _Color5 ("Projection Color 5", Color) = (1,1,1,1)
        _Falloff5 ("Falloff 5", Range(0.01, 1)) = 0.5
        _EmissionStrength5 ("Emission Strength 5", Float) = 1.0

        _MainTex6 ("Projection Texture 6", 2D) = "white" {}
        _Color6 ("Projection Color 6", Color) = (1,1,1,1)
        _Falloff6 ("Falloff 6", Range(0.01, 1)) = 0.5
        _EmissionStrength6 ("Emission Strength 6", Float) = 1.0

        _MainTex7 ("Projection Texture 7", 2D) = "white" {}
        _Color7 ("Projection Color 7", Color) = (1,1,1,1)
        _Falloff7 ("Falloff 7", Range(0.01, 1)) = 0.5
        _EmissionStrength7 ("Emission Strength 7", Float) = 1.0

        _MainTex8 ("Projection Texture 8", 2D) = "white" {}
        _Color8 ("Projection Color 8", Color) = (1,1,1,1)
        _Falloff8 ("Falloff 8", Range(0.01, 1)) = 0.5
        _EmissionStrength8 ("Emission Strength 8", Float) = 1.0

        _MainTex9 ("Projection Texture 9", 2D) = "white" {}
        _Color9 ("Projection Color 9", Color) = (1,1,1,1)
        _Falloff9 ("Falloff 9", Range(0.01, 1)) = 0.5
        _EmissionStrength9 ("Emission Strength 9", Float) = 1.0

        _MinProjectionAngle ("Min Dot Projection", Range(0, 1)) = 0.5

        [HideInInspector]_ProjectorData0 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward0 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData1 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward1 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData2 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward2 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData3 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward3 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData4 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward4 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData5 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward5 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData6 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward6 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData7 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward7 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData8 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward8 ("", Vector) = (0,0,-1)
        [HideInInspector]_ProjectorData9 ("", Vector) = (0,0,0,1)
        [HideInInspector]_ProjectorForward9 ("", Vector) = (0,0,-1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            sampler2D _BaseMap;
            sampler2D _BumpMap;

            sampler2D _MainTex0, _MainTex1, _MainTex2, _MainTex3, _MainTex4;
            sampler2D _MainTex5, _MainTex6, _MainTex7, _MainTex8, _MainTex9;

            float4 _BaseColor;

            float4 _Color0, _Color1, _Color2, _Color3, _Color4;
            float4 _Color5, _Color6, _Color7, _Color8, _Color9;

            float _Falloff0, _Falloff1, _Falloff2, _Falloff3, _Falloff4;
            float _Falloff5, _Falloff6, _Falloff7, _Falloff8, _Falloff9;

            float _EmissionStrength0, _EmissionStrength1, _EmissionStrength2, _EmissionStrength3, _EmissionStrength4;
            float _EmissionStrength5, _EmissionStrength6, _EmissionStrength7, _EmissionStrength8, _EmissionStrength9;

            float _MinProjectionAngle;

            float4 _ProjectorData0, _ProjectorData1, _ProjectorData2, _ProjectorData3, _ProjectorData4;
            float4 _ProjectorData5, _ProjectorData6, _ProjectorData7, _ProjectorData8, _ProjectorData9;

            float3 _ProjectorForward0, _ProjectorForward1, _ProjectorForward2, _ProjectorForward3, _ProjectorForward4;
            float3 _ProjectorForward5, _ProjectorForward6, _ProjectorForward7, _ProjectorForward8, _ProjectorForward9;

            struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
    float4 tangentOS : TANGENT;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 normalWS : NORMAL;
    float3 tangentWS : TEXCOORD2;
    float3 bitangentWS : TEXCOORD3;
};

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
    float3 tangentWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
    float3 bitangentWS = cross(normalWS, tangentWS) * IN.tangentOS.w;
    OUT.normalWS = normalWS;
    OUT.tangentWS = tangentWS;
    OUT.bitangentWS = bitangentWS;
    OUT.uv = IN.uv;
    return OUT;
}

half3 ApplyProjector(float3 worldPos, float3 normalWS, float4 projectorData, float3 projectorForward, sampler2D tex, float4 color, float falloff, float emission)
{
    float3 projectorPos = projectorData.xyz;
    float projectorScale = projectorData.w;
    float3 localPos = worldPos - projectorPos;
    float3 forward = normalize(projectorForward);
    float3 right = normalize(cross(float3(0,1,0), forward));
    float3 up = normalize(cross(forward, right));

    float u = dot(localPos, right) / (projectorScale * 0.5);
    float v = dot(localPos, up) / (projectorScale * 0.5);
    float angleFactor = saturate(dot(normalWS, -forward));
    angleFactor = max(angleFactor, 0.05);
    u /= angleFactor;

    float2 projUV = float2(u, v) * 0.5 + 0.5;
    float2 centeredUV = projUV - 0.5;
    float radius = length(centeredUV) * 2.0;

    float dotNormalProj = dot(normalWS, -forward);

    if (projUV.x < 0 || projUV.x > 1 || projUV.y < 0 || projUV.y > 1 || dotNormalProj < _MinProjectionAngle)
        return 0;

    float falloffMask = saturate((1.0 - radius) / falloff);

    half4 sample = tex2D(tex, projUV) * color;
    return sample.rgb * falloffMask * emission;
}

half4 frag(Varyings IN) : SV_Target
{
    half4 baseColor = tex2D(_BaseMap, IN.uv) * _BaseColor;
    half3 normalTS = UnpackNormal(tex2D(_BumpMap, IN.uv));
    half3x3 TBN = half3x3(normalize(IN.tangentWS), normalize(IN.bitangentWS), normalize(IN.normalWS));
    half3 normalWS = normalize(mul(normalTS, TBN));

    // Lighting preparation
    InputData inputData = (InputData)0;
    inputData.positionWS = IN.positionWS;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = GetWorldSpaceViewDir(IN.positionWS);
    inputData.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);

    half3 bakedGI = SampleSH(normalWS);

    Light mainLight = GetMainLight(inputData.shadowCoord);
    half3 mainLightColor = mainLight.color * saturate(dot(normalWS, mainLight.direction)) * mainLight.shadowAttenuation;

    half3 additionalLightsColor = half3(0,0,0);
    #ifdef _ADDITIONAL_LIGHTS
    uint lightsCount = GetAdditionalLightsCount();
    for (uint i = 0; i < lightsCount; ++i)
    {
        Light light = GetAdditionalLight(i, IN.positionWS);
        half NdotL = saturate(dot(normalWS, light.direction));
        additionalLightsColor += light.color * NdotL;
    }
    #endif

    half3 lighting = bakedGI + mainLightColor + additionalLightsColor;

    // Projectors
    half3 proj = 0;
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData0, _ProjectorForward0, _MainTex0, _Color0, _Falloff0, _EmissionStrength0);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData1, _ProjectorForward1, _MainTex1, _Color1, _Falloff1, _EmissionStrength1);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData2, _ProjectorForward2, _MainTex2, _Color2, _Falloff2, _EmissionStrength2);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData3, _ProjectorForward3, _MainTex3, _Color3, _Falloff3, _EmissionStrength3);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData4, _ProjectorForward4, _MainTex4, _Color4, _Falloff4, _EmissionStrength4);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData5, _ProjectorForward5, _MainTex5, _Color5, _Falloff5, _EmissionStrength5);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData6, _ProjectorForward6, _MainTex6, _Color6, _Falloff6, _EmissionStrength6);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData7, _ProjectorForward7, _MainTex7, _Color7, _Falloff7, _EmissionStrength7);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData8, _ProjectorForward8, _MainTex8, _Color8, _Falloff8, _EmissionStrength8);
    proj += ApplyProjector(IN.positionWS, normalWS, _ProjectorData9, _ProjectorForward9, _MainTex9, _Color9, _Falloff9, _EmissionStrength9);

    // Final color
    half3 finalColor = baseColor.rgb * lighting + proj;

    // Apply Fog
    finalColor = MixFog(finalColor, inputData.fogCoord);

    return half4(finalColor, baseColor.a);
}
ENDHLSL
        }
    }
}
