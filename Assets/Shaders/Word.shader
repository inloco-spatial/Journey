// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Word"
{
	Properties
	{
		_AlphaMask("AlphaMask", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseScale("NoiseScale", Float) = 0
		_NoiseStrength("_NoiseStrength", Float) = 0
		_BaseColorrgb("_BaseColor.rgb", Color) = (0,0,0,0)
		_GlowColor("GlowColor", Color) = (0,0,0,0)
		_EdgeWidth("_EdgeWidth", Float) = 0
		_BaseGlowIntensity("_BaseGlowIntensity", Float) = 0
		_GlowIntensity("_GlowIntensity", Float) = 0
		_Radius("_Radius", Range( 0 , 1)) = 0
		_HeartbeatRate("_HeartbeatRate", Float) = 0
		_PulseAmount("_PulseAmount", Range( 0 , 2)) = 6.283185
		_LightPos("_LightPos", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _AlphaMask;
		uniform float4 _AlphaMask_ST;
		uniform float4 _GlowColor;
		uniform float _HeartbeatRate;
		uniform float _PulseAmount;
		uniform float _BaseGlowIntensity;
		uniform float _Radius;
		uniform float _EdgeWidth;
		uniform float4 _LightPos;
		uniform sampler2D _NoiseTex;
		uniform float _NoiseScale;
		uniform float _NoiseStrength;
		uniform float _GlowIntensity;
		uniform float4 _BaseColorrgb;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_AlphaMask = i.uv_texcoord * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
			float4 tex2DNode1 = tex2D( _AlphaMask, uv_AlphaMask );
			float lerpResult48 = lerp( 1.0 , abs( sin( ( _Time.y * ( _HeartbeatRate / 60.0 ) * 6.283185 ) ) ) , _PulseAmount);
			float pulse40 = lerpResult48;
			float _Radius24 = _Radius;
			float _EdgeWidth26 = _EdgeWidth;
			float4 temp_cast_0 = (( _Radius24 - _EdgeWidth26 )).xxxx;
			float4 temp_cast_1 = (_Radius24).xxxx;
			float4 temp_cast_3 = (0.0).xxxx;
			float4 noisyDist12 = ( distance( float4( i.uv_texcoord, 0.0 , 0.0 ) , _LightPos ) + ( ( tex2D( _NoiseTex, ( ( i.uv_texcoord * _NoiseScale ) + ( _Time.y * 0.1 ) ) ) - temp_cast_3 ) * _NoiseStrength ) );
			float4 smoothstepResult30 = smoothstep( temp_cast_0 , temp_cast_1 , noisyDist12);
			float4 temp_cast_4 = (_Radius24).xxxx;
			float4 temp_cast_5 = (( _Radius24 + _EdgeWidth26 )).xxxx;
			float4 smoothstepResult31 = smoothstep( temp_cast_4 , temp_cast_5 , noisyDist12);
			float4 edge22 = ( smoothstepResult30 - smoothstepResult31 );
			float4 glow67 = ( ( tex2DNode1 * _GlowColor * pulse40 * _BaseGlowIntensity ) + ( _GlowColor * edge22 * _GlowIntensity * pulse40 ) );
			o.Emission = ( glow67 + ( tex2DNode1 * _BaseColorrgb ) ).rgb;
			float4 temp_cast_7 = (_Radius).xxxx;
			float4 temp_cast_8 = (( _Radius - _EdgeWidth )).xxxx;
			float4 smoothstepResult3 = smoothstep( temp_cast_7 , temp_cast_8 , noisyDist12);
			float4 reveal19 = smoothstepResult3;
			float4 temp_output_21_0 = ( tex2DNode1 * reveal19 );
			o.Alpha = temp_output_21_0.r;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
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
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1316.571,916.9525;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1923.131,386.6388;Inherit;False;Property;_Radius;_Radius;10;0;Create;True;0;0;0;True;0;False;0;0.912;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-1738.244,-73.71301;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;31;-2007.095,97.09414;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2369.59,237.4757;Inherit;False;26;_EdgeWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-2387,159.9126;Inherit;False;24;_Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-2155.095,173.8942;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-2260.695,361.0944;Inherit;False;12;noisyDist;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-2071.3,1037.782;Inherit;True;Property;_NoiseTex;NoiseTex;1;0;Create;True;0;0;0;True;0;False;-1;None;8426c50263ce8564b8b40b1b28c6f0f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-2241.425,1099.325;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2263.343,1537.573;Inherit;False;Property;_HeartbeatRate;_HeartbeatRate;11;0;Create;True;0;0;0;True;0;False;0;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;-2177.477,1433.31;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;41;-1617.763,1513.963;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;42;-1732.698,1514.784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1881.476,1517.31;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-2064.677,1526.11;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;60;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-1408.903,1494.802;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2071.077,1637.31;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;6.283185;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1643.884,1601.308;Inherit;False;Property;_PulseAmount;_PulseAmount;12;0;Create;True;0;0;0;True;0;False;6.283185;0.8;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1146.96,1521.219;Inherit;False;pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-176.4504,251.5114;Inherit;False;19;reveal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-395.9072,43.8581;Inherit;True;Property;_AlphaMask;AlphaMask;0;0;Create;True;0;0;0;True;0;False;-1;None;41f53e0e586cb3246ba2012f9aecec7b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-370.4423,1166.009;Inherit;False;22;edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;192.5338,753.5475;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-22.28229,1120.469;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;392.2129,1037.819;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;543.5469,1042.798;Inherit;False;glow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-90.98706,922.6193;Inherit;False;40;pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;59;-397.5421,946.951;Inherit;False;Property;_GlowColor;GlowColor;6;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.8564041,0.4936916,0.1511298,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;62;-344.0422,1363.608;Inherit;False;40;pulse;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-349.6422,1271.607;Inherit;False;Property;_GlowIntensity;_GlowIntensity;9;0;Create;True;0;0;0;True;0;False;0;17.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-36.9281,1006.628;Inherit;False;Property;_BaseGlowIntensity;_BaseGlowIntensity;8;0;Create;True;0;0;0;True;0;False;0;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;70;-344.1623,401.3481;Inherit;False;Property;_BaseColorrgb;_BaseColor.rgb;5;0;Create;True;0;0;0;True;0;False;0,0,0,0;1,0.7843137,0.4745098,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;80.60419,118.199;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;272.9524,384.4559;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;434.0875,296.1725;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;277.1913,87.73547;Inherit;False;67;glow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;917.0222,26.65751;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Word;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.07;True;True;0;False;Transparent;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;3;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SmoothstepOpNode;30;-2191.096,-117.3058;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-2405.496,-255.7058;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-2677.705,-278.309;Inherit;False;24;_Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2665.496,-199.7059;Inherit;False;26;_EdgeWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-2611.895,-113.3057;Inherit;False;24;_Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-2619.895,-10.10588;Inherit;False;12;noisyDist;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2280.695,82.69421;Inherit;False;24;_Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1572.314,-75.09686;Inherit;False;edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-1065.211,921.8921;Inherit;False;noisyDist;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-2649.631,953.7345;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-2431.824,1037.725;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2628.254,1091.847;Inherit;False;Property;_NoiseScale;NoiseScale;2;0;Create;True;0;0;0;True;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-2650.224,1233.725;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-2455.823,1231.325;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1985.78,1246.454;Inherit;False;Constant;_05;0.5;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-1659.342,1103.09;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1462.171,1105.753;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1793.345,718.729;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;10;-1486.945,825.1292;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;8;-1980.545,841.9289;Inherit;False;Property;_LightPos;_LightPos;13;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.76,0.5,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1671.772,1220.153;Inherit;False;Property;_NoiseStrength;_NoiseStrength;4;0;Create;True;0;0;0;True;0;False;0;0.295;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1834.968,462.0734;Inherit;False;Property;_EdgeWidth;_EdgeWidth;7;0;Create;True;0;0;0;True;0;False;0;0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1638.621,191.7587;Inherit;False;_Radius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1603.698,306.963;Inherit;False;12;noisyDist;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;6;-1593.199,428.3759;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;3;-1413.241,372.8822;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1223.729,372.8984;Inherit;False;reveal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1682.168,563.7066;Inherit;False;_EdgeWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;17;0;10;0
WireConnection;17;1;16;0
WireConnection;23;0;30;0
WireConnection;23;1;31;0
WireConnection;31;0;38;0
WireConnection;31;1;34;0
WireConnection;31;2;37;0
WireConnection;37;0;36;0
WireConnection;37;1;35;0
WireConnection;2;1;54;0
WireConnection;54;0;53;0
WireConnection;54;1;56;0
WireConnection;41;0;42;0
WireConnection;42;0;46;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;46;2;47;0
WireConnection;44;0;43;0
WireConnection;48;1;41;0
WireConnection;48;2;49;0
WireConnection;40;0;48;0
WireConnection;63;0;1;0
WireConnection;63;1;59;0
WireConnection;63;2;65;0
WireConnection;63;3;69;0
WireConnection;60;0;59;0
WireConnection;60;1;58;0
WireConnection;60;2;61;0
WireConnection;60;3;62;0
WireConnection;66;0;63;0
WireConnection;66;1;60;0
WireConnection;67;0;66;0
WireConnection;21;0;1;0
WireConnection;21;1;20;0
WireConnection;71;0;1;0
WireConnection;71;1;70;0
WireConnection;72;0;68;0
WireConnection;72;1;71;0
WireConnection;0;2;72;0
WireConnection;0;9;21;0
WireConnection;30;0;32;0
WireConnection;30;1;28;0
WireConnection;30;2;33;0
WireConnection;28;0;25;0
WireConnection;28;1;27;0
WireConnection;22;0;23;0
WireConnection;12;0;17;0
WireConnection;53;0;51;0
WireConnection;53;1;52;0
WireConnection;56;0;55;0
WireConnection;13;0;2;0
WireConnection;13;1;14;0
WireConnection;16;0;13;0
WireConnection;16;1;15;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;24;0;5;0
WireConnection;6;0;5;0
WireConnection;6;1;7;0
WireConnection;3;0;18;0
WireConnection;3;1;5;0
WireConnection;3;2;6;0
WireConnection;19;0;3;0
WireConnection;26;0;7;0
ASEEND*/
//CHKSM=63874FDFFE2F461E921C075A5FAB9FCF6282B912