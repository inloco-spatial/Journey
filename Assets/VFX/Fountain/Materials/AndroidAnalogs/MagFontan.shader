// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MagFontan"
{
	Properties
	{
		_noise("noise", 2D) = "white" {}
		_Scale("Scale", Float) = 0
		_CircleSize("_CircleSize", Float) = 0
		_WaveDensity("_WaveDensity", Float) = 0
		_DistortionSpeed("_DistortionSpeed", Float) = 0
		_RandomIdleDistortion("_RandomIdleDistortion", Float) = 0
		_RandomDistortion("_RandomDistortion", Float) = 0
		_WaveStrength("_WaveStrength", Float) = 0
		_Smooth("Smooth", Range( 0 , 1)) = 0
		_Met("Met", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_Color("Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _Scale;
		uniform float _CircleSize;
		uniform float _WaveDensity;
		uniform float _DistortionSpeed;
		uniform float _WaveStrength;
		uniform float _RandomIdleDistortion;
		uniform float _RandomDistortion;
		uniform sampler2D _noise;
		uniform float4 _noise_ST;
		uniform float4 _Color;
		uniform float _Met;
		uniform float _Smooth;
		uniform float _Alpha;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 centeredUV14 = ( ( i.uv_texcoord - float2( 0.5,0.5 ) ) * _Scale );
			float L23 = abs( ( length( centeredUV14 ) - _CircleSize ) );
			float falloff25 = ( 1.0 / ( pow( L23 , 2.0 ) + 1.0 ) );
			float2 uv_noise = i.uv_texcoord * _noise_ST.xy + _noise_ST.zw;
			o.Normal = ( ( float4( ( ( centeredUV14 * cos( ( ( L23 * _WaveDensity ) - ( _Time.y * _DistortionSpeed ) ) ) ) * _WaveStrength ), 0.0 , 0.0 ) + ( ( ( _RandomIdleDistortion / falloff25 ) + _RandomDistortion ) * tex2D( _noise, uv_noise ) ) ) * falloff25 ).rgb;
			o.Albedo = _Color.rgb;
			o.Metallic = _Met;
			o.Smoothness = _Smooth;
			o.Alpha = _Alpha;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-2101.322,211.1523;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-1824.121,291.6323;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1831.321,390.8323;Inherit;False;Property;_Scale;Scale;1;0;Create;True;0;0;0;True;0;False;0;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1652.84,304.5923;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1469.296,296.0499;Inherit;False;centeredUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;8;-1769.503,696.3668;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-1567.104,701.9669;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1796.704,817.9666;Inherit;False;Property;_CircleSize;_CircleSize;2;0;Create;True;0;0;0;True;0;False;0;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-2030.843,732.8672;Inherit;False;14;centeredUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;11;-1397.948,692.9694;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-535.7084,720.4874;Inherit;False;Property;_WaveDensity;_WaveDensity;3;0;Create;True;0;0;0;True;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;16;-258.4417,817.8817;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;126.5815,683.6968;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;20;356.4214,530.8168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-282.9688,575.6731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;248.2612,447.617;Inherit;False;14;centeredUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-539.6472,573.507;Inherit;False;23;L;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1263.779,691.2928;Inherit;False;L;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;27;-1799.113,1328.436;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1629.513,1345.236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1478.313,1278.837;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1303.002,1254.525;Inherit;False;falloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-2005.513,1318.036;Inherit;False;23;L;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-502.2648,1144.212;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-299.0648,1165.813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-775.0648,1117.813;Inherit;False;Property;_RandomIdleDistortion;_RandomIdleDistortion;5;0;Create;True;0;0;0;True;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-603.0648,1272.213;Inherit;False;Property;_RandomDistortion;_RandomDistortion;6;0;Create;True;0;0;0;True;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;5.336307,846.7178;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-102.2648,1217.813;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-489.5758,1389.834;Inherit;True;Property;_noise;noise;0;0;Create;True;0;0;0;False;0;False;-1;None;0dcf93a9db0c86a43815eca0f10b39e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-240.8052,937.5606;Inherit;False;Property;_DistortionSpeed;_DistortionSpeed;4;0;Create;True;0;0;0;True;0;False;0;5.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;515.5419,479.857;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;920.9767,901.6315;Inherit;False;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;721.4684,610.1895;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;1164.022,896.5679;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-706.754,1202.432;Inherit;False;25;falloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;857.9221,1057.365;Inherit;False;25;falloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;1443.039,688.8802;Inherit;False;25;falloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;422.1433,708.3925;Inherit;False;Property;_WaveStrength;_WaveStrength;7;0;Create;True;0;0;0;True;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1974.387,650.815;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;MagFontan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;43;1607.934,853.4487;Inherit;False;Property;_Smooth;Smooth;8;0;Create;True;0;0;0;True;0;False;0;0.146;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;1614.567,779.6644;Inherit;False;Property;_Met;Met;9;0;Create;True;0;0;0;True;0;False;0;0.789;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;1609.767,925.2642;Inherit;False;Property;_Alpha;Alpha;10;0;Create;True;0;0;0;True;0;False;0;0.633;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;1667.967,568.4642;Inherit;False;Property;_Color;Color;11;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;6;0;4;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;14;0;7;0
WireConnection;8;0;15;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;11;0;9;0
WireConnection;19;0;12;0
WireConnection;19;1;18;0
WireConnection;20;0;19;0
WireConnection;12;0;24;0
WireConnection;12;1;13;0
WireConnection;23;0;11;0
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;29;1;28;0
WireConnection;25;0;29;0
WireConnection;32;0;31;0
WireConnection;32;1;30;0
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;36;0;34;0
WireConnection;36;1;1;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;39;0;38;0
WireConnection;39;1;36;0
WireConnection;38;0;22;0
WireConnection;38;1;37;0
WireConnection;40;0;39;0
WireConnection;40;1;41;0
WireConnection;0;0;46;0
WireConnection;0;1;40;0
WireConnection;0;3;44;0
WireConnection;0;4;43;0
WireConnection;0;9;45;0
ASEEND*/
//CHKSM=36E041B1F55CCA7B6CBFFFF5323D3646CF8D4B9C