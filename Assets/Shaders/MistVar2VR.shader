// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MistVar2VR"
{
	Properties
	{
		_HeightColorLow("_HeightColorLow", Color) = (0,0,0,0)
		_HeightColorHigh("_HeightColorHigh", Color) = (0,0,0,0)
		_HeightStart("_HeightStart", Float) = 0
		_HeightEnd("_HeightEnd", Float) = 0
		_TerrainTintColor("_TerrainTintColor", Color) = (0,0,0,0)
		_FogDistance("_FogDistance", Float) = 0
		_FogDensity("_FogDensity", Float) = 0
		_FogColor("_FogColor", Color) = (0,0,0,0)
		_HeightFogMaxY("_HeightFogMaxY", Float) = 0
		_HeightFogStrength("_HeightFogStrength", Float) = 0
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_NoiseScale("_NoiseScale", Float) = 0
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_NoiseStrength("_NoiseStrength", Float) = 0
		_FadeDistance("_FadeDistance", Float) = 0
		_AlphaTest("AlphaTest", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float eyeDepth;
		};

		uniform float4 _HeightColorLow;
		uniform float4 _HeightColorHigh;
		uniform float _HeightStart;
		uniform float _HeightEnd;
		uniform float4 _TerrainTintColor;
		uniform float _FogDistance;
		uniform float _FogDensity;
		uniform float4 _FogColor;
		uniform float _HeightFogMaxY;
		uniform float _HeightFogStrength;
		uniform sampler2D _NoiseTexture;
		uniform float _NoiseScale;
		uniform float2 _NoiseSpeed;
		uniform float _NoiseStrength;
		uniform float _FadeDistance;
		uniform float _AlphaTest;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 temp_cast_0 = (_HeightStart).xxx;
			float4 lerpResult11 = lerp( _HeightColorLow , _HeightColorHigh , float4( saturate( ( ( ase_vertex3Pos - temp_cast_0 ) / ( _HeightEnd - _HeightStart ) ) ) , 0.0 ));
			float cameraDepthFade96 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
			float4 lerpResult20 = lerp( lerpResult11 , _TerrainTintColor , pow( saturate( ( cameraDepthFade96 / _FogDistance ) ) , ( 1.0 / _FogDensity ) ));
			float4 baseCol23 = lerpResult20;
			float depth33 = cameraDepthFade96;
			float _FogDistance32 = _FogDistance;
			float clampResult28 = clamp( ( ( _HeightFogMaxY - ase_vertex3Pos.y ) / _HeightFogMaxY ) , 0.0 , 1.0 );
			float heightFog31 = ( clampResult28 * _HeightFogStrength );
			float3 ase_worldPos = i.worldPos;
			float4 appendResult105 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 noise56 = ( tex2D( _NoiseTexture, ( ( appendResult105 * _NoiseScale ) + float4( ( _NoiseSpeed * _Time.y ), 0.0 , 0.0 ) ).xy ) * _NoiseStrength );
			float _FogDensity64 = _FogDensity;
			float4 temp_cast_4 = (( 1.0 / _FogDensity64 )).xxxx;
			float4 lerpResult67 = lerp( baseCol23 , _FogColor , pow( saturate( ( saturate( ( depth33 / _FogDistance32 ) ) + heightFog31 + noise56 ) ) , temp_cast_4 ));
			float dotResult70 = dot( lerpResult67 , float4( float3(0.3,0.59,0.11) , 0.0 ) );
			float gray74 = dotResult70;
			float3 temp_cast_6 = (gray74).xxx;
			o.Emission = temp_cast_6;
			float cameraDepthFade95 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 1.0);
			float smoothstepResult84 = smoothstep( 0.0 , _FadeDistance , pow( cameraDepthFade95 , _AlphaTest ));
			float Alpha87 = saturate( smoothstepResult84 );
			o.Alpha = Alpha87;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float1 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.x = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack1.x;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
Node;AmplifyShaderEditor.PosVertexDataNode;3;-2051.191,-122.8846;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1635.991,13.11537;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;5;-1824.791,-50.08459;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;7;-1826.391,117.1154;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2049.591,22.7154;Inherit;False;Property;_HeightStart;_HeightStart;2;0;Create;True;0;0;0;True;0;False;0;-0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2049.591,100.3154;Inherit;False;Property;_HeightEnd;_HeightEnd;3;0;Create;True;0;0;0;True;0;False;0;10.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1;-1495.264,-10.0526;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;9;-1648.398,-391.134;Inherit;False;Property;_HeightColorLow;_HeightColorLow;0;0;Create;True;0;0;0;True;0;False;0,0,0,0;1,0.8684741,0.614,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-1649.78,-221.0719;Inherit;False;Property;_HeightColorHigh;_HeightColorHigh;1;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.8745098,0.8745098,0.8745098,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;11;-1314.226,-293.726;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;16;-1274.125,346.9642;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-1454.925,375.7641;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;17;-1076.125,383.3795;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;20;-849.5897,203.9623;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;19;-1400.125,543.9648;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1600.582,-786.3635;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;52;-2027.381,-575.9641;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;38;-2137.375,-873.1276;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1767.048,-713.4046;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1840.068,-852.5374;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;51;-1983.382,-686.3633;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;13;0;Create;True;0;0;0;True;0;False;0,0;-0.01,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;40;-2091.244,-953.1193;Inherit;False;Property;_NoiseScale;_NoiseScale;12;0;Create;True;0;0;0;False;0;False;0;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1256.089,-968.7401;Inherit;False;Property;_NoiseStrength;_NoiseStrength;14;0;Create;True;0;0;0;False;0;False;0;2.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1083.401,-863.4533;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-899.4011,-867.1945;Inherit;False;noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1786.118,766.5118;Inherit;False;Property;_HeightFogMaxY;_HeightFogMaxY;8;0;Create;True;0;0;0;False;0;False;0;4.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;27;-1321.938,854.868;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;28;-1095.028,843.7832;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1187.828,989.3829;Inherit;False;Property;_HeightFogStrength;_HeightFogStrength;9;0;Create;True;0;0;0;False;0;False;0;-0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-930.2275,896.5831;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-766.3616,869.0756;Inherit;False;heightFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1706.936,526.4885;Inherit;False;_FogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1621.645,612.605;Inherit;False;Property;_FogDensity;_FogDensity;6;0;Create;True;0;0;0;True;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1617.277,687.0695;Inherit;False;_FogDensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-122.5494,917.2541;Inherit;False;31;heightFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-112.8675,790.9882;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-353.9465,775.1135;Inherit;False;33;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;238.1898,846.7255;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;37;39.93242,793.3889;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;60;409.3583,847.7073;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;61;687.7581,886.1072;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;498.1583,976.5071;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-363.679,854.9931;Inherit;False;32;_FogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-114.5217,985.0445;Inherit;False;56;noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;21;-1239.932,133.6338;Inherit;False;Property;_TerrainTintColor;_TerrainTintColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5054116,0.6141415,0.7058823,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;73;498.1694,1157.961;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;294.415,1194.259;Inherit;False;33;depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;-1382.288,-856.8038;Inherit;True;Property;_Noise;Noise;10;0;Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1644.141,-991.5044;Inherit;True;Property;_NoiseTexture;Noise Texture;11;0;Create;True;0;0;0;False;0;False;None;8426c50263ce8564b8b40b1b28c6f0f3;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1514.518,829.9223;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;25;-1788.389,888.466;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1705.708,459.0031;Inherit;False;Property;_FogDistance;_FogDistance;5;0;Create;True;0;0;0;True;0;False;0;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;96;-1732.981,327.6189;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1487.254,288.2287;Inherit;False;depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-637.1122,205.4069;Inherit;False;baseCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;78;1603.95,882.2776;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;1194.61,811.642;Inherit;False;74;gray;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;98;1413.262,786.9617;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;1292.203,1018.365;Inherit;False;77;desatF;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;69;619.0165,686.169;Inherit;False;Property;_FogColor;_FogColor;7;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.4573689,0.5463018,0.6309999,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;67;894.4316,836.4377;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;71;917.9029,509.7757;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0.3,0.59,0.11;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;70;1213.311,547.3652;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;1327.373,564.3083;Inherit;False;gray;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;647.8033,590.3384;Inherit;False;23;baseCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;1098.978,1215.121;Inherit;False;desatF;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;923.3099,1209.763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;730.6526,1333.321;Inherit;False;Property;_DesatStrength;_DesatStrength;10;0;Create;True;0;0;0;False;0;False;0;0.634;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;101;705.8395,1180.836;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;271.6451,1036.656;Inherit;False;64;_FogDensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;103;2264.179,496.7071;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;MistVar2VR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.WorldPosInputsNode;104;-2532.109,-711.2756;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;105;-2290.932,-685.2227;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;1963.621,854.3848;Inherit;False;87;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;1882.382,1446.72;Inherit;False;Property;_FadeDistance;_FadeDistance;15;0;Create;True;0;0;0;True;0;False;0;1.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;86;2327.605,1419.443;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;84;2128.872,1378.437;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;1884.874,1539.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;1662.474,1570.931;Inherit;False;Property;_AlphaTest;AlphaTest;16;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;80;1566.005,1470.027;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;2504.033,1380.574;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;1736.749,1342.18;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;108;1994.341,1246.231;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;95;1437.936,1231.391;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;7;0;8;0
WireConnection;7;1;4;0
WireConnection;1;0;6;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;11;2;1;0
WireConnection;16;0;15;0
WireConnection;15;0;96;0
WireConnection;15;1;14;0
WireConnection;17;0;16;0
WireConnection;17;1;19;0
WireConnection;20;0;11;0
WireConnection;20;1;21;0
WireConnection;20;2;17;0
WireConnection;19;1;18;0
WireConnection;50;0;53;0
WireConnection;50;1;45;0
WireConnection;45;0;51;0
WireConnection;45;1;52;0
WireConnection;53;0;105;0
WireConnection;53;1;40;0
WireConnection;55;0;42;0
WireConnection;55;1;54;0
WireConnection;56;0;55;0
WireConnection;27;0;26;0
WireConnection;27;1;24;0
WireConnection;28;0;27;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;31;0;30;0
WireConnection;32;0;14;0
WireConnection;64;0;18;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;57;0;37;0
WireConnection;57;1;59;0
WireConnection;57;2;58;0
WireConnection;37;0;36;0
WireConnection;60;0;57;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;62;1;65;0
WireConnection;73;0;68;0
WireConnection;73;1;65;0
WireConnection;42;0;49;0
WireConnection;42;1;50;0
WireConnection;26;0;24;0
WireConnection;26;1;25;2
WireConnection;33;0;96;0
WireConnection;23;0;20;0
WireConnection;78;0;98;0
WireConnection;78;1;67;0
WireConnection;78;2;99;0
WireConnection;98;0;97;0
WireConnection;98;1;97;0
WireConnection;98;2;97;0
WireConnection;67;0;66;0
WireConnection;67;1;69;0
WireConnection;67;2;61;0
WireConnection;70;0;67;0
WireConnection;70;1;71;0
WireConnection;74;0;70;0
WireConnection;77;0;76;0
WireConnection;76;0;101;0
WireConnection;76;1;75;0
WireConnection;101;0;73;0
WireConnection;103;2;74;0
WireConnection;103;9;88;0
WireConnection;105;0;104;1
WireConnection;105;1;104;3
WireConnection;86;0;84;0
WireConnection;84;0;108;0
WireConnection;84;2;85;0
WireConnection;106;0;80;0
WireConnection;106;1;107;0
WireConnection;87;0;86;0
WireConnection;83;0;95;0
WireConnection;83;1;80;0
WireConnection;108;0;95;0
WireConnection;108;1;107;0
ASEEND*/
//CHKSM=9CB083CC0C6AA09177E0FA64387E37B3EE82E3E7