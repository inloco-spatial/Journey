// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StarWater"
{
	Properties
	{
		_WaveSpeed("_WaveSpeed", Float) = 0
		_WaveAmplitude1("_WaveAmplitude", Float) = 0
		_WaveFrequency("_WaveFrequency", Float) = 0
		_BaseMap("_BaseMap", 2D) = "white" {}
		_BaseColorrgb("_BaseColor.rgb", Color) = (0,0,0,0)
		_FresnelPower("_FresnelPower", Float) = 0
		_Vector0("Vector 0", Vector) = (0,1,10,0)
		_ReflectionMap("_ReflectionMap", CUBE) = "white" {}
		_ReflectionStrength("_ReflectionStrength", Float) = 0
		_FogColorrgb("_FogColor.rgb", Color) = (0,0,0,0)
		_FogStart("_FogStart", Float) = 0
		_FogEnd("_FogEnd", Float) = 0
		_UVDistorsion("UVDistorsion", Float) = 1
		_Stars("Stars", 2D) = "white" {}
		_StarMap("StarMap", 2D) = "white" {}
		_StarMapPow("StarMapPow", Float) = 0
		_StarTimeScale("StarTimeScale", Float) = 0
		_StarTiling("StarTiling", Float) = 0
		_StarMapTiling("StarMapTiling", Float) = 0
		_StarEmiPow("StarEmiPow", Float) = 0
		_StarEmiMul("StarEmiMul", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float eyeDepth;
		};

		uniform float _WaveFrequency;
		uniform float _WaveSpeed;
		uniform float _WaveAmplitude1;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform float _UVDistorsion;
		uniform float4 _BaseColorrgb;
		uniform samplerCUBE _ReflectionMap;
		uniform float3 _Vector0;
		uniform float _FresnelPower;
		uniform float _ReflectionStrength;
		uniform float4 _FogColorrgb;
		uniform float _FogStart;
		uniform float _FogEnd;
		uniform sampler2D _Stars;
		uniform float _StarTiling;
		uniform float _StarTimeScale;
		uniform sampler2D _StarMap;
		uniform float _StarMapTiling;
		uniform float _StarMapPow;
		uniform float _StarEmiPow;
		uniform float _StarEmiMul;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float _WaveFrequency227 = _WaveFrequency;
			float t222 = ( _Time.y * _WaveSpeed );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 worldToObj263 = mul( unity_WorldToObject, float4( ase_vertex3Pos, 1 ) ).xyz;
			float _WaveAmplitude228 = _WaveAmplitude1;
			float wave220 = ( sin( ( _WaveFrequency227 * ( t222 + worldToObj263.x ) ) ) * cos( ( _WaveFrequency227 * ( t222 + worldToObj263.z ) ) ) * _WaveAmplitude228 );
			float wsPos232 = wave220;
			float3 temp_cast_0 = (wsPos232).xxx;
			v.vertex.xyz += temp_cast_0;
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float _WaveFrequency227 = _WaveFrequency;
			float t222 = ( _Time.y * _WaveSpeed );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorld297 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 break289 = ( objToWorld297 * _UVDistorsion );
			float4 appendResult265 = (float4(sin( ( _WaveFrequency227 * ( t222 + break289.x ) ) ) , cos( ( _WaveFrequency227 * ( t222 + break289.z ) ) ) , 0.0 , 0.0));
			float _WaveAmplitude228 = _WaveAmplitude1;
			float4 ripple266 = ( appendResult265 * _WaveAmplitude228 );
			float3 objToWorld53 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult49 = normalize( ( _WorldSpaceCameraPos - objToWorld53 ) );
			float dotResult54 = dot( _Vector0 , normalizeResult49 );
			float4 lerpResult63 = lerp( ( tex2D( _BaseMap, ( float4( uv_BaseMap, 0.0 , 0.0 ) + ripple266 ).xy ) * _BaseColorrgb ) , texCUBE( _ReflectionMap, reflect( ( normalizeResult49 * float3( -1,-1,-1 ) ) , float3( 0,1,0 ) ) ) , ( pow( ( 1.0 - saturate( dotResult54 ) ) , _FresnelPower ) * _ReflectionStrength ));
			float4 baseCol96 = lerpResult63;
			float cameraDepthFade209 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
			float4 lerpResult206 = lerp( baseCol96 , _FogColorrgb , saturate( ( ( cameraDepthFade209 - _FogStart ) / ( _FogEnd - _FogStart ) ) ));
			o.Albedo = lerpResult206.rgb;
			float2 temp_cast_3 = (_StarTiling).xx;
			float TimeScale334 = _StarTimeScale;
			float mulTime311 = _Time.y * TimeScale334;
			float2 uv_TexCoord310 = i.uv_texcoord * temp_cast_3 + pow( frac( ( mulTime311 * float2( 75.91,51.72 ) ) ) , 0.59 );
			float2 temp_cast_4 = (_StarMapTiling).xx;
			float mulTime324 = _Time.y * TimeScale334;
			float2 uv_TexCoord314 = i.uv_texcoord * temp_cast_4 + pow( frac( ( mulTime324 * float2( 70.31,134.2 ) ) ) , 0.2846 );
			float4 temp_cast_7 = (_StarMapPow).xxxx;
			float4 lerpResult304 = lerp( float4( 0,0,0,0 ) , tex2D( _Stars, uv_TexCoord310 ) , pow( tex2D( _StarMap, ( float4( uv_TexCoord314, 0.0 , 0.0 ) + ripple266 ).xy ) , temp_cast_7 ));
			float4 temp_cast_8 = (_StarEmiPow).xxxx;
			o.Emission = ( round( pow( lerpResult304 , temp_cast_8 ) ) * _StarEmiMul ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.WorldSpaceCameraPos;50;-2521.272,283.0537;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2230.005,309.3278;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;52;-2665.1,451.598;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1857.89,190.1267;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;61;-1678.01,186.8329;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;62;-1455.579,27.44973;Inherit;True;Property;_ReflectionMap;_ReflectionMap;7;0;Create;True;0;0;0;False;0;False;-1;None;4dc48e49776993543bb31fe5ac727b2d;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;54;-1945.392,432.2983;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;53;-2475.947,444.8569;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;55;-2161.146,492.4568;Inherit;False;Property;_Vector0;Vector 0;6;0;Create;True;0;0;0;True;0;False;0,1,10;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;49;-2069.282,303.4141;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1203.939,373.8909;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1412.98,533.8109;Inherit;False;Property;_ReflectionStrength;_ReflectionStrength;8;0;Create;True;0;0;0;True;0;False;0;0.181;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;58;-1371.709,380.4983;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1608.741,437.6876;Inherit;False;Property;_FresnelPower;_FresnelPower;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;-1750.059,349.1871;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-1593.091,329.7589;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-1013.848,151.7438;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-786.5956,182.0957;Inherit;False;baseCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;206;465.2098,826.2565;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;207;55.54078,766.0437;Inherit;False;Property;_FogColorrgb;_FogColor.rgb;9;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.6509804,0.5764706,0.4823529,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CameraDepthFade;209;-594.8594,869.2437;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;212;-112.4592,978.8439;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-491.6593,990.8437;Inherit;False;Property;_FogStart;_FogStart;10;0;Create;True;0;0;0;True;0;False;0;203.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-488.4594,1093.243;Inherit;False;Property;_FogEnd;_FogEnd;11;0;Create;True;0;0;0;True;0;False;0;41.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;211;-296.4592,919.6436;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;215;-309.2593,1090.044;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;208;45.4607,978.044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;85.57899,681.6246;Inherit;False;96;baseCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-1730.872,1716.788;Inherit;False;wsPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;356.5055,1211.233;Inherit;False;232;wsPos;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;223;-4390.39,1236.61;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-4179.99,1262.21;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;-4188.828,1134.295;Inherit;False;Property;_WaveFrequency;_WaveFrequency;2;0;Create;True;0;0;0;True;0;False;0;2.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-3920.763,1232.547;Inherit;False;t;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-3906.429,1136.695;Inherit;False;_WaveFrequency;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-4412.139,1329.412;Inherit;False;Property;_WaveSpeed;_WaveSpeed;0;0;Create;True;0;0;0;True;0;False;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-4194.067,1034.38;Inherit;False;Property;_WaveAmplitude1;_WaveAmplitude;1;0;Create;True;0;0;0;True;0;False;0;0.394;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-3875.837,1036.363;Inherit;False;_WaveAmplitude;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;-2825.513,1652.364;Inherit;False;wave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-3713.686,1599.372;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-3524.287,1546.426;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-3991.332,1574.094;Inherit;False;222;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-3802,1516.24;Inherit;False;227;_WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-3487.622,1855.305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-3723.075,1803.558;Inherit;False;227;_WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-3686.151,1893.022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;217;-3297.105,1823.82;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-3084.303,1633.44;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;216;-3307.841,1568.659;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-3395.074,2000.493;Inherit;False;228;_WaveAmplitude;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;276;-3458.874,2570.541;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;277;-3694.327,2518.793;Inherit;False;227;_WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;278;-3657.403,2608.258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;-3911.047,2575.78;Inherit;False;222;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;284;-3268.357,2539.056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;-2632.016,2585.992;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;265;-3032.782,2384.97;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;28;-4544.236,1760.03;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;263;-4259.492,1745.203;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;30;-3925.79,1808.029;Inherit;False;222;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;282;-5320.74,2491.525;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;297;-5107.701,2490.27;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;272;-3647.499,2371.809;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-3458.1,2318.863;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-3925.145,2346.531;Inherit;False;222;t;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-3735.813,2288.677;Inherit;False;227;_WaveFrequency;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;286;-3241.654,2341.096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;266;-2229.096,2576.652;Inherit;False;ripple;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-2862.326,2649.327;Inherit;False;228;_WaveAmplitude;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;289;-4372.35,2508.078;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-4634.168,2510.581;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-4849.368,2614.579;Inherit;False;Property;_UVDistorsion;UVDistorsion;12;0;Create;True;0;0;0;False;0;False;1;1.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;48;-1667.669,-811.5121;Inherit;False;Property;_BaseColorrgb;_BaseColor.rgb;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.470588,0.470588,0.470588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1410.997,-895.0516;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;-1706.689,-1022.193;Inherit;True;Property;_BaseMap;_BaseMap;3;0;Create;True;0;0;0;True;0;False;-1;None;ad2e56cb1f90c0f49a27f9a4fe3dc407;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;250;-2282.333,-1028.75;Inherit;False;0;44;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;315;-268.4198,-561.8459;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;317;-261.2199,-645.8463;Inherit;False;Property;_StarMapTiling;StarMapTiling;19;0;Create;True;0;0;0;False;0;False;0;2.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-470.0202,-528.2463;Inherit;False;Property;_StarMapScale;StarMapScale;16;0;Create;True;0;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;311;-1026.921,-1249.235;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;319;-810.0347,-1273.841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;81.25,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;320;-1021.234,-1143.44;Inherit;False;Constant;_Vector1;Vector 1;21;0;Create;True;0;0;0;False;0;False;75.91,51.72;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;321;-655.7855,-1263.109;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;322;-523.7853,-1243.909;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.59;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;324;-690.4825,-330.3622;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;-473.5964,-354.9682;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;81.25,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;327;-684.7955,-224.5675;Inherit;False;Constant;_Vector2;Vector 1;21;0;Create;True;0;0;0;False;0;False;70.31,134.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;328;-319.3472,-344.2362;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;314;-76.93069,-657.3455;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;329;-187.3468,-325.0363;Inherit;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.2846;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;304;724.2649,-1193.494;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;1438.701,-1194.655;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;333;1073.6,-1181.258;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;309;876.3011,-1033.055;Inherit;False;Property;_StarEmiPow;StarEmiPow;20;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;1172.4,-1009.258;Inherit;False;Property;_StarEmiMul;StarEmiMul;21;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;-1456.471,-1258.996;Inherit;False;Property;_StarTimeScale;StarTimeScale;17;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;-1268.533,-1261.194;Inherit;False;TimeScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;336;1260.266,-1174.764;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;335;-897.6258,-313.9569;Inherit;False;334;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;337;1320.026,-616.6667;Inherit;False;232;wsPos;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;303;216.5344,-1430.651;Inherit;True;Property;_Stars;Stars;13;0;Create;True;0;0;0;False;0;False;-1;None;3021abdf120b0684186d6a942f573d86;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;296;-1859.296,-1090.243;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;-2095.939,-920.1686;Inherit;False;266;ripple;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-375.2744,-1430.963;Inherit;False;Property;_StarTiling;StarTiling;18;0;Create;True;0;0;0;False;0;False;0;8.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;310;-176.3868,-1452.563;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;305;391.8145,-793.1693;Inherit;True;Property;_StarMap;StarMap;14;0;Create;True;0;0;0;False;0;False;-1;None;0dcf93a9db0c86a43815eca0f10b39e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;307;547.4148,-600.3695;Inherit;False;Property;_StarMapPow;StarMapPow;15;0;Create;True;0;0;0;False;0;False;0;1.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;306;746.7146,-806.6693;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;339;24.49442,-450.5023;Inherit;False;266;ripple;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;338;248.5131,-693.0562;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1736.799,-987.363;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;StarWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;50;0
WireConnection;51;1;53;0
WireConnection;60;0;49;0
WireConnection;61;0;60;0
WireConnection;62;1;61;0
WireConnection;54;0;55;0
WireConnection;54;1;49;0
WireConnection;53;0;52;0
WireConnection;49;0;51;0
WireConnection;64;0;58;0
WireConnection;64;1;65;0
WireConnection;58;0;57;0
WireConnection;58;1;59;0
WireConnection;56;0;54;0
WireConnection;57;1;56;0
WireConnection;63;0;46;0
WireConnection;63;1;62;0
WireConnection;63;2;64;0
WireConnection;96;0;63;0
WireConnection;206;0;205;0
WireConnection;206;1;207;0
WireConnection;206;2;208;0
WireConnection;212;0;211;0
WireConnection;212;1;215;0
WireConnection;211;0;209;0
WireConnection;211;1;210;0
WireConnection;215;0;214;0
WireConnection;215;1;210;0
WireConnection;208;0;212;0
WireConnection;232;0;220;0
WireConnection;224;0;223;0
WireConnection;224;1;225;0
WireConnection;222;0;224;0
WireConnection;227;0;226;0
WireConnection;228;0;218;0
WireConnection;220;0;219;0
WireConnection;29;0;27;0
WireConnection;29;1;263;1
WireConnection;34;0;33;0
WireConnection;34;1;29;0
WireConnection;35;0;36;0
WireConnection;35;1;32;0
WireConnection;32;0;30;0
WireConnection;32;1;263;3
WireConnection;217;0;35;0
WireConnection;219;0;216;0
WireConnection;219;1;217;0
WireConnection;219;2;229;0
WireConnection;216;0;34;0
WireConnection;276;0;277;0
WireConnection;276;1;278;0
WireConnection;278;0;279;0
WireConnection;278;1;289;2
WireConnection;284;0;276;0
WireConnection;267;0;265;0
WireConnection;267;1;287;0
WireConnection;265;0;286;0
WireConnection;265;1;284;0
WireConnection;263;0;28;0
WireConnection;297;0;282;0
WireConnection;272;0;274;0
WireConnection;272;1;289;0
WireConnection;273;0;275;0
WireConnection;273;1;272;0
WireConnection;286;0;273;0
WireConnection;266;0;267;0
WireConnection;289;0;298;0
WireConnection;298;0;297;0
WireConnection;298;1;299;0
WireConnection;46;0;44;0
WireConnection;46;1;48;0
WireConnection;44;1;296;0
WireConnection;315;0;316;0
WireConnection;311;0;334;0
WireConnection;319;0;311;0
WireConnection;319;1;320;0
WireConnection;321;0;319;0
WireConnection;322;0;321;0
WireConnection;324;0;335;0
WireConnection;326;0;324;0
WireConnection;326;1;327;0
WireConnection;328;0;326;0
WireConnection;314;0;317;0
WireConnection;314;1;329;0
WireConnection;329;0;328;0
WireConnection;304;1;303;0
WireConnection;304;2;306;0
WireConnection;308;0;336;0
WireConnection;308;1;331;0
WireConnection;333;0;304;0
WireConnection;333;1;309;0
WireConnection;334;0;312;0
WireConnection;336;0;333;0
WireConnection;303;1;310;0
WireConnection;296;0;250;0
WireConnection;296;1;268;0
WireConnection;310;0;313;0
WireConnection;310;1;322;0
WireConnection;305;1;338;0
WireConnection;306;0;305;0
WireConnection;306;1;307;0
WireConnection;338;0;314;0
WireConnection;338;1;339;0
WireConnection;0;0;206;0
WireConnection;0;2;308;0
WireConnection;0;11;337;0
ASEEND*/
//CHKSM=23E407771D2DF854EC0CBF46FCFB0251376FF167