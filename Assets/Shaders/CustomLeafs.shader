// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CustomLeafs"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.23
		_BaseMap("BaseMap", 2D) = "white" {}
		[Normal]_NormalMap("NormalMap", 2D) = "bump" {}
		_CutoutMap("CutoutMap", 2D) = "white" {}
		_WindDirection("WindDirection", Vector) = (0,0,0,0)
		_WindFrequency("WindFrequency", Float) = 0
		_WindSpeed("WindSpeed", Float) = 0
		_WindStrength("_WindStrength", Float) = 0
		[HDR]_EmiColor("EmiColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _WindDirection;
		uniform float _WindFrequency;
		uniform float _WindSpeed;
		uniform float _WindStrength;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform float4 _EmiColor;
		uniform sampler2D _CutoutMap;
		uniform float4 _CutoutMap_ST;
		uniform float _Cutoff = 0.23;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 break14 = ase_vertex3Pos;
			float4 appendResult15 = (float4(break14.x , break14.z , 0.0 , 0.0));
			float4 appendResult16 = (float4(_WindDirection.x , _WindDirection.z , 0.0 , 0.0));
			float dotResult5 = dot( appendResult15 , appendResult16 );
			float lerpResult29 = lerp( 0.0 , ( ( sin( ( ( dotResult5 * _WindFrequency ) + ( _Time.y * _WindSpeed ) ) ) + sin( ( ( ( ase_vertex3Pos.x + ase_vertex3Pos.z ) * 1.3 * _WindFrequency ) + ( ( _Time.y * _WindSpeed ) * 1.7 ) ) ) ) * 0.5 * _WindStrength ) , v.texcoord.xy.y);
			float4 temp_output_33_0 = ( _WindDirection * lerpResult29 );
			v.vertex.xyz += temp_output_33_0.xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float4 tex2DNode1 = tex2D( _BaseMap, uv_BaseMap );
			o.Albedo = tex2DNode1.rgb;
			o.Emission = _EmiColor.rgb;
			o.Alpha = 1;
			float2 uv_CutoutMap = i.uv_texcoord * _CutoutMap_ST.xy + _CutoutMap_ST.zw;
			clip( tex2D( _CutoutMap, uv_CutoutMap ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.DotProductOpNode;5;-1863.627,565.2269;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1696.427,597.2269;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2160.427,450.827;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-2109.226,662.0269;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;17;-2352.257,1030.97;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-1496.427,651.627;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-2350.955,1187.968;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1900.427,792.4268;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1751.745,1340.655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;13;-1238.827,569.2271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;27;-1212.627,1276.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1362.095,1258.673;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1725.227,792.4268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1918.827,873.2269;Inherit;False;Property;_WindSpeed;WindSpeed;6;0;Create;True;0;0;0;True;0;False;0;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1026.591,1071.046;Inherit;False;Property;_WindStrength;_WindStrength;7;0;Create;True;0;0;0;True;0;False;0;0.199;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;6;-2455.629,743.6271;Inherit;False;Property;_WindDirection;WindDirection;4;0;Create;True;0;0;0;True;0;False;0,0,0,0;1,1,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-300.8701,762.8969;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.5;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;4;-2498.03,527.6269;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-999.8664,919.5652;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;235.04,45.75999;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;CustomLeafs;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.23;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.LerpOp;29;-545.6134,893.5736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-803.0807,912.7867;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;-868.191,1169.447;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-1940.074,679.9121;Inherit;False;Property;_WindFrequency;WindFrequency;5;0;Create;True;0;0;0;True;0;False;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1592.1,1351.156;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-2082.521,1086.121;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1669.518,1118.499;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1.3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-1963.113,1324.943;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;14;-2300.909,440.3469;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PosVertexDataNode;34;-489.6417,636.6785;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-84.61765,674.9924;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-699.6302,353.9209;Inherit;True;Property;_CutoutMap;CutoutMap;3;0;Create;True;0;0;0;True;0;False;-1;None;a899dc50d5f637446a5282c7d6b4b38e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-687.2216,94.16614;Inherit;True;Property;_NormalMap;NormalMap;2;1;[Normal];Create;True;0;0;0;True;0;False;-1;None;9ca1482a1895f8e42a054f40da3dc282;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-723.1464,-70.22803;Inherit;True;Property;_BaseMap;BaseMap;1;0;Create;True;0;0;0;True;0;False;-1;None;bed1a4b7041acac4e874d7b6ac31fe6d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-243.2426,-41.87196;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;36;-523.9497,-352.7091;Inherit;False;Property;_EmiColor;EmiColor;8;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;0.7843137,1.333333,1.639216,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;5;0;15;0
WireConnection;5;1;16;0
WireConnection;8;0;5;0
WireConnection;8;1;7;0
WireConnection;15;0;14;0
WireConnection;15;1;14;2
WireConnection;16;0;6;1
WireConnection;16;1;6;3
WireConnection;9;0;8;0
WireConnection;9;1;11;0
WireConnection;25;0;23;0
WireConnection;25;1;12;0
WireConnection;13;0;9;0
WireConnection;27;0;22;0
WireConnection;22;0;20;0
WireConnection;22;1;26;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;33;0;6;0
WireConnection;33;1;29;0
WireConnection;28;0;13;0
WireConnection;28;1;27;0
WireConnection;0;0;1;0
WireConnection;0;1;3;0
WireConnection;0;2;36;0
WireConnection;0;10;2;0
WireConnection;0;11;33;0
WireConnection;29;1;30;0
WireConnection;29;2;32;2
WireConnection;30;0;28;0
WireConnection;30;2;31;0
WireConnection;26;0;25;0
WireConnection;19;0;17;1
WireConnection;19;1;18;3
WireConnection;20;0;19;0
WireConnection;20;2;7;0
WireConnection;14;0;4;0
WireConnection;35;0;34;0
WireConnection;35;1;33;0
WireConnection;37;0;1;0
ASEEND*/
//CHKSM=1C4680A4CAA3C17833A6344023F9AE7E24AF0551