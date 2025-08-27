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

void FountainVert_half(float3 ObjectPosition, half3 ObjectNormal, half3 ObjectTangent, half3 ObjectBitangent, half2 UV0, half2 UV1, out float3 VertexPosition, out half3 VertexNormal, out half3 VertexTangent)
{
	VertexPosition = ObjectPosition;
	VertexNormal = ObjectNormal;
	VertexTangent = ObjectTangent;
}

void FountainWaterfall_half(half2 uv0, out half3 TangentNormal)
{
	half denwasity = _DensityTex.Sample(sampler_DensityTex, uv0).r;
	half3 noise = perlinNoised(uv0 + _Time.y * half2(0, _ScrollNoise), _Scale, _Time.y * _Rotation, 0);
	
	if(density - _Distortion * noise.x - _Cutoff < 0.0)
		discard;

	half3 normal;
	normal.xy = noise.yz;
	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	TangentNormal = normal;

}
