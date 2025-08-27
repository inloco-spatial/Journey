#include "NoiseFunctions.hlsl"

#if defined(UNITY_SINGLE_PASS_STEREO)
	float2 StereoTransformScreenSpaceTex(float2 uv)
	{
		// TODO: RVS support can be added here, if Universal decides to support it
		float4 scaleOffset = unity_StereoScaleOffset[unity_StereoEyeIndex];
		return saturate(uv) * scaleOffset.xy + scaleOffset.zw;
	}
#else
	#define StereoTransformScreenSpaceTex(uv) uv
#endif
/*
#ifndef REQUIRE_DEPTH_TEXTURE
Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;
#endif
*/
#ifndef REQUIRE_OPAQUE_TEXTURE
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
Texture2DArray _CameraOpaqueTexture;
#else
Texture2D _CameraOpaqueTexture;
#endif
SamplerState sampler_CameraOpaqueTexture;
#endif

half3 SampleSceneColor(half2 uv)
{
#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
	return _CameraOpaqueTexture.Sample(sampler_CameraOpaqueTexture, float3(StereoTransformScreenSpaceTex(uv), unity_StereoEyeIndex)).rgb;
#else
	return _CameraOpaqueTexture.Sample(sampler_CameraOpaqueTexture, StereoTransformScreenSpaceTex(uv)).rgb;
#endif
}

half4 TriPlanarSample(Texture2D t, SamplerState s, in float3 position, in half3 normal)
{
	normal *= normal;
	return 
		normal.x * t.Sample(s, position.zy) +
		normal.y * t.Sample(s, position.xz) +
		normal.z * t.Sample(s, position.xy);
}

void FountainVert_half(float3 ObjectPosition, half3 ObjectNormal, half3 ObjectTangent, half3 ObjectBitangent, half2 UV0, half2 UV1, out float3 VertexPosition, out half3 VertexNormal, out half3 VertexTangent)
{
	VertexPosition = ObjectPosition;
	VertexNormal = ObjectNormal;
	VertexTangent = ObjectTangent;
}

void FountainParticlesSurf_half(float3 WorldPosition, half3 WorldNormal, half3 WorldDir, 
half3 ViewVector, half3 ViewNormal, half3 ViewTangent, half3 ViewBitangent, 
half4 ScreenPosition, half2 uv0, half Seed, half Speed, half3 Size, half3 Velocity, 
half4 VertexColor, out half3 Albedo, out half Alpha, out half Smoothness, 
out half3 Emission, out half3 TangentNormal, out half3 TangentWorld)
{
	half3 normal;
	normal.xy = uv0 * 4 - 2;
	normal.xy += (_Distortion * 0.3 + 0.7 * Speed * _DistortionBySpeed) * perlinNoised(uv0 * half2(Speed * _DistortionBySpeed + 1.0, 1.0), _Scale, _Time.y * _DistortionSpeed, Seed * 100.0).yz;
	float l = dot(normal.xy, normal.xy);
	float dl = length(float2(ddx(l), ddy(l)));
	normal.z = sqrt(1.0 - saturate(l));
	TangentNormal = normal;

	half3x3 tangentToView = half3x3(ViewTangent, ViewBitangent, ViewNormal);
	//half3 tangentToView = ViewTangent;
	half3 viewNormal = normalize(mul(normal, tangentToView));
	TangentWorld = mul((float3x3)UNITY_MATRIX_I_V, viewNormal);

	half3 reflectDir = reflect(WorldDir, TangentWorld);
	half3 reflectionColor = _FakeReflection.Sample(sampler_FakeReflection, reflectDir).rgb;
	
	half3 clipNormal = mul((float3x3)GetViewToHClipMatrix(), viewNormal);
	half2 uv = ScreenPosition.xy + _ScreenDistortion * clipNormal.xy * saturate(rcp(ViewVector.z));
	half3 color = SampleSceneColor(uv);
	
	Albedo = _Color.rgb;
	Alpha = saturate((VertexColor.a * _Color.a - l) / dl);
	Smoothness = 1.0;
	Emission = color + reflectionColor * _ReflectionTint.rgb;
}