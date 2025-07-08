Shader "Custom/TerrainFogBlend_TintTerrain-VRFixed" {
    Properties {
        _HeightColorLow ("Low Height Color", Color) = (1,0.85,0.65,1)
        _HeightColorHigh ("High Height Color", Color) = (1,0.92,0.75,1)
        _HeightStart ("Height Start (m)", Float) = 0.0
        _HeightEnd ("Height End (m)", Float) = 20.0
        _TerrainTintColor ("Terrain Tint Color", Color) = (1,0.9,0.8,1)
        _FogDistance ("Tint & Fog Distance", Float) = 40.0
        _FogDensity ("Tint & Fog Density", Range(0.1,5)) = 1.5
        _FogColor ("Fog Color", Color) = (0.1,0.1,0.1,1)
        _HeightFogMaxY ("Height Fog Max Y", Float) = 5.0
        _HeightFogStrength ("Height Fog Strength", Range(0,1)) = 0.7
        _DesatStrength ("Desaturation Strength", Range(0,1)) = 0.5
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Range(0.1,10)) = 2.0
        _NoiseSpeed ("Noise Speed", Range(0,5)) = 0.1
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.3
        _FadeDistance ("Object Fade Distance", Float) = 3.0
    }

    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ UNITY_XR_ENABLED ENABLE_VR
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            float4 _HeightColorLow, _HeightColorHigh;
            float _HeightStart, _HeightEnd;
            float4 _TerrainTintColor, _FogColor;
            float _FogDistance, _FogDensity;
            float _HeightFogMaxY, _HeightFogStrength, _DesatStrength;
            sampler2D _NoiseTex; float _NoiseScale, _NoiseSpeed, _NoiseStrength;
            float _FadeDistance;

            struct Attributes { float4 posOS : POSITION; };
            struct Varyings { float4 posH : SV_POSITION; float3 posWS : TEXCOORD0; float4 scrPos : TEXCOORD1; };

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.posH = TransformObjectToHClip(IN.posOS.xyz);
                OUT.posWS = TransformObjectToWorld(IN.posOS.xyz);
                OUT.scrPos = ComputeScreenPos(OUT.posH);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {
                #if UNITY_XR_ENABLED || ENABLE_VR
                    float h = saturate((IN.posWS.y - _HeightStart)/(_HeightEnd - _HeightStart));
                    float3 col = lerp(_HeightColorLow.rgb, _HeightColorHigh.rgb, h);
                    float2 noiseUV = IN.posWS.xz * _NoiseScale + _Time.y * _NoiseSpeed;
                    float noise = tex2D(_NoiseTex, noiseUV).r * _NoiseStrength;
                    col *= 1.0 - noise;
                    return float4(col, 1);
                #else
                    float hNorm = saturate((IN.posWS.y - _HeightStart) / (_HeightEnd - _HeightStart));
                    float3 baseCol = lerp(_HeightColorLow.rgb, _HeightColorHigh.rgb, hNorm);
                    float depth = LinearEyeDepth(IN.posH.z, _ZBufferParams);

                    float terrainTintFactor = pow(saturate(depth / _FogDistance), 1.0 / _FogDensity);
                    baseCol = lerp(baseCol, _TerrainTintColor.rgb, terrainTintFactor);

                    float heightFog = clamp((_HeightFogMaxY - IN.posWS.y) / _HeightFogMaxY, 0, 1) * _HeightFogStrength;

                    float baseFog = saturate(depth / _FogDistance);
                    float2 nUV = IN.scrPos.xy / IN.scrPos.w * _NoiseScale + _Time.y * _NoiseSpeed;
                    float noise = (tex2D(_NoiseTex, nUV).r - 0.5) * _NoiseStrength;
                    float fogFactor = saturate(baseFog + heightFog + noise);
                    fogFactor = pow(fogFactor, 1.0 / _FogDensity);
                    baseCol = lerp(baseCol, _FogColor.rgb, fogFactor);

                    float gray = dot(baseCol, float3(0.3,0.59,0.11));
                    float desatF = saturate(depth / _FogDistance) * _DesatStrength;
                    baseCol = lerp(baseCol, gray.xxx, desatF);

                    float sceneD = SampleSceneDepth(IN.scrPos.xy / IN.scrPos.w);
                    float sceneLin = LinearEyeDepth(sceneD, _ZBufferParams);
                    float diff = depth - sceneLin;
                    float alpha = saturate(smoothstep(0, _FadeDistance, diff));

                    return float4(baseCol, alpha);
                #endif
            }
            ENDHLSL
        }
    }
}