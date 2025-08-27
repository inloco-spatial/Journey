// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WaterShader"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_CircleSize("_CircleSize", Float) = 0
		_Scale("Scale", Vector) = (60,60,0,0)
		_Scale1("Scale", Vector) = (60,60,0,0)
		_WaveDensity("_WaveDensity", Float) = 0
		_DistortionSpeed("DistortionSpeed", Float) = 0
		_RandomIdleDistortion("RandomIdleDistortion", Float) = 0
		_RandomDistortion("RandomDistortion", Float) = 0
		_WaveStrength("WaveStrength", Float) = 0
		_GPass("GPass", Range( 0 , 1)) = 0
		_Smooth("Smooth", Range( 0 , 1)) = 0
		_Met("Met", Range( 0 , 1)) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		_NormalPow("NormalPow", Float) = 0
		_NoiseOffest("NoiseOffest", Float) = 0.1
		_Color("Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _Noise;
		sampler2D _Sampler60125;
		uniform float _NoiseOffest;
		uniform float2 _Scale1;
		uniform float _NormalPow;
		uniform float _RandomIdleDistortion;
		uniform float2 _Scale;
		uniform float _CircleSize;
		uniform float _RandomDistortion;
		uniform float _WaveDensity;
		uniform float _DistortionSpeed;
		uniform float _WaveStrength;
		uniform float4 _Color;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _GPass;
		uniform float4 _Color0;
		uniform float _Met;
		uniform float _Smooth;


		float3 PerturbNormal107_g6( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g6 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g6 = ase_worldNormal;
			float2 temp_cast_0 = (_NoiseOffest).xx;
			float2 temp_output_1_0_g7 = temp_cast_0;
			float2 appendResult10_g7 = (float2(( (temp_output_1_0_g7).x * i.uv_texcoord.x ) , ( i.uv_texcoord.y * (temp_output_1_0_g7).y )));
			float2 temp_output_11_0_g7 = float2( 0,0 );
			float2 panner18_g7 = ( ( (temp_output_11_0_g7).x * _Time.y ) * float2( 1,0 ) + i.uv_texcoord);
			float2 panner19_g7 = ( ( _Time.y * (temp_output_11_0_g7).y ) * float2( 0,1 ) + i.uv_texcoord);
			float2 appendResult24_g7 = (float2((panner18_g7).x , (panner19_g7).y));
			float2 temp_output_47_0_g7 = _Scale1;
			float2 uv_TexCoord78_g7 = i.uv_texcoord * float2( 2,2 );
			float2 temp_output_31_0_g7 = ( uv_TexCoord78_g7 - float2( 1,1 ) );
			float2 appendResult39_g7 = (float2(frac( ( atan2( (temp_output_31_0_g7).x , (temp_output_31_0_g7).y ) / 6.28318548202515 ) ) , length( temp_output_31_0_g7 )));
			float2 panner54_g7 = ( ( (temp_output_47_0_g7).x * _Time.y ) * float2( 1,0 ) + appendResult39_g7);
			float2 panner55_g7 = ( ( _Time.y * (temp_output_47_0_g7).y ) * float2( 0,1 ) + appendResult39_g7);
			float2 appendResult58_g7 = (float2((panner54_g7).x , (panner55_g7).y));
			float height107_g6 = tex2D( _Noise, ( ( (tex2D( _Sampler60125, ( appendResult10_g7 + appendResult24_g7 ) )).rg * 1.0 ) + ( float2( 1,1 ) * appendResult58_g7 ) ) ).r;
			float scale107_g6 = _NormalPow;
			float3 localPerturbNormal107_g6 = PerturbNormal107_g6( surf_pos107_g6 , surf_norm107_g6 , height107_g6 , scale107_g6 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g6 = mul( ase_worldToTangent, localPerturbNormal107_g6);
			float3 noise37 = worldToTangentDir42_g6;
			float2 temp_cast_2 = (0.5).xx;
			float2 centeredUV5 = ( ( i.uv_texcoord - temp_cast_2 ) * _Scale );
			float L26 = abs( ( length( centeredUV5 ) - _CircleSize ) );
			float temp_output_36_0 = ( ( _RandomIdleDistortion / L26 ) + _RandomDistortion );
			float2 wave40 = ( centeredUV5 * cos( ( ( L26 * _WaveDensity ) - ( _Time.y * _DistortionSpeed ) ) ) );
			float falloff31 = ( 1.0 / ( pow( L26 , 2.0 ) + 1.0 ) );
			float3 normalizeResult48 = normalize( ( ( ( noise37 * temp_output_36_0 ) + float3( ( wave40 * _WaveStrength ) ,  0.0 ) ) * falloff31 ) );
			float3 normal47 = normalizeResult48;
			o.Normal = normal47;
			o.Albedo = _Color.rgb;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 lerpResult66 = lerp( ase_grabScreenPosNorm , float4( normal47 , 0.0 ) , _GPass);
			float4 screenColor52 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,lerpResult66.xy);
			o.Emission = ( screenColor52 * _Color0 ).rgb;
			o.Metallic = _Met;
			o.Smoothness = _Smooth;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.RangedFloatNode;17;-2120.527,900.3986;Inherit;False;Property;_WaveDensity;_WaveDensity;4;0;Create;True;0;0;0;False;0;False;0;1.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1859.727,831.5979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1649.327,917.9982;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;19;-2065.327,1042.799;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1874.127,1045.998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2049.327,1131.598;Inherit;False;Property;_DistortionSpeed;DistortionSpeed;5;0;Create;True;0;0;0;True;0;False;0;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;23;-1456.527,929.9985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1236.527,846.7986;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-3054.892,712.6133;Inherit;False;centeredUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;-1086.223,1335.082;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1216.622,1358.281;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-1360.623,1355.082;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-1546.604,1346.01;Inherit;False;26;L;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-2202.395,1812.006;Inherit;False;26;L;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;34;-2017.737,1768.183;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2172.938,1897.784;Inherit;False;Property;_RandomDistortion;RandomDistortion;7;0;Create;True;0;0;0;True;0;False;0;-0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1702.478,1737.863;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1889.912,2049.356;Inherit;False;Property;_WaveStrength;WaveStrength;8;0;Create;True;0;0;0;True;0;False;0;-0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1499.512,1828.556;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2259.484,1734.394;Inherit;False;Property;_RandomIdleDistortion;RandomIdleDistortion;6;0;Create;True;0;0;0;True;0;False;0;-0.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1849.738,1779.383;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1711.512,1985.352;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1305.899,1833.138;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;48;-1072.941,1869.538;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-1551.34,2053.617;Inherit;False;31;falloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;52;-412.7396,1005.313;Inherit;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;66;-690.5629,1023.399;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;73.52319,1067.003;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;81;-172.4768,1110.003;Inherit;False;Property;_Color0;Color 0;12;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.5018866,0.5018866,0.5018866,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-924.2651,1331.128;Inherit;False;falloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;69;-1011.162,981.7986;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1356.463,866.8338;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;WaterShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-166.4272,541.896;Inherit;False;Property;_NormalPow;NormalPow;13;0;Create;True;0;0;0;False;0;False;0;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1961.886,1647.235;Inherit;False;37;noise;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-1680.55,1605.839;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;4;-363.8917,335.6572;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;0;True;0;False;-1;None;8426c50263ce8564b8b40b1b28c6f0f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;99;-1729.151,1475.535;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-3625.291,592.6139;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-3390.891,626.2139;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-3224.491,711.8135;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;15;-3430.86,784.5424;Inherit;False;Property;_Scale;Scale;2;0;Create;True;0;0;0;False;0;False;60,60;60,60;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;9;-3579.691,707.8135;Inherit;False;Constant;_05;0.5;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;107;293.5609,413.8674;Inherit;False;Normal From Height;-1;;6;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;1;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-822.3009,1833.139;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-973.9937,1240.211;Inherit;False;Property;_GPass;GPass;9;0;Create;True;0;0;0;True;0;False;0;0.01;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1480.636,819.8984;Inherit;False;5;centeredUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-943.92,1159.907;Inherit;False;47;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-993.3781,857.1762;Inherit;False;wave;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1920.577,1958.284;Inherit;False;40;wave;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;587.2498,865.7251;Inherit;False;47;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;682.745,390.7868;Inherit;False;noise;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-2220.49,752.6829;Inherit;False;L;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;12;-2781.26,730.1434;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-2622.06,735.7427;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;16;-2456.302,710.2825;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2817.26,802.9427;Inherit;False;Property;_CircleSize;_CircleSize;1;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-2580.874,845.0249;Inherit;False;_CircleSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;125;-796.2465,303.8854;Inherit;False;RadialUVDistortion;-1;;7;051d65e7699b41a4c800363fd0e822b2;0;7;60;SAMPLER2D;_Sampler60125;False;1;FLOAT2;1,1;False;11;FLOAT2;0,0;False;65;FLOAT;1;False;68;FLOAT2;1,1;False;47;FLOAT2;1,1;False;29;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;103;-1090.371,404.0662;Inherit;False;Property;_Scale1;Scale;3;0;Create;True;0;0;0;False;0;False;60,60;0,-0.03;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;96;-1059.222,325.2688;Inherit;False;Property;_NoiseOffest;NoiseOffest;14;0;Create;True;0;0;0;True;0;False;0.1;-0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;698.2604,1245.267;Inherit;False;Property;_Smooth;Smooth;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;755.7505,1114.36;Inherit;False;Property;_Met;Met;11;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;127;1108.081,711.3422;Inherit;False;Property;_Color;Color;15;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;18;0;26;0
WireConnection;18;1;17;0
WireConnection;22;0;18;0
WireConnection;22;1;20;0
WireConnection;20;0;19;0
WireConnection;20;1;21;0
WireConnection;23;0;22;0
WireConnection;24;0;25;0
WireConnection;24;1;23;0
WireConnection;5;0;11;0
WireConnection;30;1;29;0
WireConnection;29;0;28;0
WireConnection;28;0;27;0
WireConnection;34;0;32;0
WireConnection;34;1;33;0
WireConnection;39;0;38;0
WireConnection;39;1;36;0
WireConnection;44;0;39;0
WireConnection;44;1;43;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;48;0;45;0
WireConnection;52;0;66;0
WireConnection;66;0;69;0
WireConnection;66;1;109;0
WireConnection;66;2;68;0
WireConnection;82;0;52;0
WireConnection;82;1;81;0
WireConnection;31;0;30;0
WireConnection;0;0;127;0
WireConnection;0;1;86;0
WireConnection;0;2;82;0
WireConnection;0;3;126;0
WireConnection;0;4;80;0
WireConnection;92;0;38;0
WireConnection;92;1;36;0
WireConnection;4;1;125;0
WireConnection;99;0;38;0
WireConnection;99;1;36;0
WireConnection;8;0;7;0
WireConnection;8;1;9;0
WireConnection;11;0;8;0
WireConnection;11;1;15;0
WireConnection;107;20;4;0
WireConnection;107;110;91;0
WireConnection;47;0;48;0
WireConnection;40;0;24;0
WireConnection;37;0;107;40
WireConnection;26;0;16;0
WireConnection;12;0;5;0
WireConnection;13;0;12;0
WireConnection;13;1;14;0
WireConnection;16;0;13;0
WireConnection;112;0;14;0
WireConnection;125;1;96;0
WireConnection;125;47;103;0
ASEEND*/
//CHKSM=7E891E7B4EA9B9A1D02F842A5ED2B6E8C49DE70E