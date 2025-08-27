#include "NoiseFunctions.hlsl"

void FountainVert_half(float3 ObjectPosition, half3 ObjectNormal, half3 ObjectTangent, half3 ObjectBitangent, half2 UV0, half2 UV1, out float3 VertexPosition, out half3 VertexNormal, out half3 VertexTangent)
{
	VertexPosition = ObjectPosition;
	VertexNormal = ObjectNormal;
	VertexTangent = ObjectTangent;
}
float2 ParallaxMapping(sampler2D reliefmap, float2 p, float3 viewDir, float depthScale) 
{
	return p - viewDir.xy * depthScale;
}

void FountainSurf_half(float3 WorldPosition, half3 WorldNormal, half3 WorldDir, 
half3 ViewVector, half3 ViewNormal, half3 ViewTangent, half3 ViewBitangent, half2 uv0, 
out half3 TangentNormal) 
{
	half3 noise = perlinNoised(uv0, _Scale, _Time.y * _RotationSpeed, 0.0);
	half2 centeredUV = (uv0 - 0.5) * _Scale;
	half L = abs(length(centeredUV) - _CircleSize);
	half2 wave = centeredUV * cos(_WaveDensity * L - _Time.y * _DistortionSpeed);

	half falloff = 1.0 / (L*L + 1.0);
	half3 normal = 1.0;
	normal.xy = ((_RandomDistortion + _RandomIdleDistortion / falloff) * noise.yz + wave * _WaveStrength) * falloff;
	normal = normalize(normal);
	TangentNormal = normal;
	
	
	
}
