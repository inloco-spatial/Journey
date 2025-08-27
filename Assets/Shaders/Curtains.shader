// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Curtains"
{
	Properties
	{
		_BottomHeight("_BottomHeight", Float) = 0
		_Cutoff("_Cutoff", Range( 0 , 1)) = 0
		_WindSpeed("_WindSpeed", Float) = 0
		_LeftWindWidth("_LeftWindWidth", Float) = 0
		_RightWindWidth("_RightWindWidth", Float) = 0
		_WindAmplitude("_WindAmplitude", Float) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_OpasityMask("Opasity Mask", 2D) = "white" {}
		_AlbedoTint("Albedo Tint", Color) = (0,0,0,0)
		_LightPower("_LightPower", Float) = 0
		_LightPowertEX("_LightPowertEX", Float) = 0
		_AmbientColor("_AmbientColor", Color) = (0,0,0,0)
		[HDR]_LightColor("_LightColor", Color) = (0,0,0,0)
		[HDR]_LightMap("_LightMap", 2D) = "white" {}
		_FogStart("_FogStart", Float) = 0
		_FogEnd("_FogEnd", Float) = 0
		_FogColor("_FogColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _BottomHeight;
		uniform float _WindSpeed;
		uniform float _WindAmplitude;
		uniform float _LeftWindWidth;
		uniform float _RightWindWidth;
		uniform float4 _AmbientColor;
		uniform float4 _LightColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _LightPower;
		uniform sampler2D _LightMap;
		uniform float4 _LightMap_ST;
		uniform float _LightPowertEX;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _AlbedoTint;
		uniform float4 _FogColor;
		uniform float _FogStart;
		uniform float _FogEnd;
		uniform sampler2D _OpasityMask;
		uniform float4 _OpasityMask_ST;
		uniform float _Cutoff;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float _BottomHeight8 = _BottomHeight;
			float smoothstepResult20 = smoothstep( _LeftWindWidth , 0.0 , v.texcoord.xy.x);
			float smoothstepResult23 = smoothstep( ( 1.0 - _RightWindWidth ) , 1.0 , v.texcoord.xy.x);
			float temp_output_28_0 = ( ( 1.0 - saturate( ( v.texcoord.xy.y / _BottomHeight8 ) ) ) * sin( ( ( v.texcoord.xy.x * UNITY_PI ) + ( _Time.y * _WindSpeed ) ) ) * _WindAmplitude * ( smoothstepResult20 + smoothstepResult23 ) );
			float ifLocalVar3 = 0;
			if( v.texcoord.xy.y < _BottomHeight8 )
				ifLocalVar3 = temp_output_28_0;
			float3 temp_cast_0 = (ifLocalVar3).xxx;
			v.vertex.xyz += temp_cast_0;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult62 = normalize( ase_worldlightDir );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float dotResult63 = dot( normalizeResult62 , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) );
			float2 uv_LightMap = i.uv_texcoord * _LightMap_ST.xy + _LightMap_ST.zw;
			float4 temp_cast_0 = (_LightPowertEX).xxxx;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 baseRGBA47 = ( tex2D( _Albedo, uv_Albedo ) * _AlbedoTint );
			float4 colLit74 = ( ( _AmbientColor + ( _LightColor * pow( saturate( dotResult63 ) , _LightPower ) ) ) * pow( tex2D( _LightMap, uv_LightMap ) , temp_cast_0 ) * baseRGBA47 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorld95 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 1 ) ).xyz;
			float4 lerpResult86 = lerp( colLit74 , _FogColor , saturate( ( ( distance( objToWorld95 , _WorldSpaceCameraPos ) - _FogStart ) / ( _FogEnd - _FogStart ) ) ));
			float4 finalC89 = lerpResult86;
			float2 uv_OpasityMask = i.uv_texcoord * _OpasityMask_ST.xy + _OpasityMask_ST.zw;
			float4 tex2DNode39 = tex2D( _OpasityMask, uv_OpasityMask );
			clip( tex2DNode39.r - _Cutoff);
			float4 alpha49 = finalC89;
			o.Emission = alpha49.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.GetLocalVarNode;9;-1779.934,899.9415;Inherit;False;8;_BottomHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-1531.134,854.3416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-1382.334,853.5415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1776.734,775.9415;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;20;-1505.929,1669.895;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1775.19,1691.957;Inherit;False;Property;_LeftWindWidth;_LeftWindWidth;3;0;Create;True;0;0;0;False;0;False;0;0.218;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-1785.646,1542.309;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;25;-1714.286,1941.109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1794.287,1806.71;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;23;-1510.286,1895.509;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1247.462,1792.904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-867.765,1492.595;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1924.688,1939.51;Inherit;False;Property;_RightWindWidth;_RightWindWidth;4;0;Create;True;0;0;0;False;0;False;0;0.201;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;3;-332.6649,1381.766;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-653.2414,1332.422;Inherit;False;_BottomHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-438.7444,1588.114;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-696.9563,1188.807;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1241.772,1540.595;Inherit;False;Property;_WindAmplitude;_WindAmplitude;5;0;Create;True;0;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;14;-1902.732,1195.116;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1480.699,1158.663;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1910.023,1268.02;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1655.67,1134.362;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1690.501,1268.02;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1905.099,1347.033;Inherit;False;Property;_WindSpeed;_WindSpeed;2;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1926.224,1067.938;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;34;-1336.6,1219.999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1222.576,828.2668;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1;-914.1103,1681.903;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-856.4412,1334.822;Inherit;False;Property;_BottomHeight;_BottomHeight;0;0;Create;True;0;0;0;True;0;False;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;-150.6249,481.5378;Inherit;True;Property;_OpasityMask;Opasity Mask;8;0;Create;True;0;0;0;True;0;False;-1;None;86ca22a8d55fbf746bd9c9dc349d92be;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;889.2839,548.9424;Inherit;False;alpha;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;56;3.516152,685.5399;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClipNode;58;554.8959,539.2946;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;51;225.9966,710.2195;Inherit;False;Property;_Cutoff;_Cutoff;1;0;Create;True;0;0;0;True;0;False;0;0.668;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;158.1998,607.0954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-334.0055,-103.3992;Inherit;True;Property;_Albedo;Albedo;6;0;Create;True;0;0;0;True;0;False;-1;None;44416036001d7fc4b835cebc00d17344;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;46;-306.5964,84.96542;Inherit;False;Property;_AlbedoTint;Albedo Tint;9;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.852,0.7878709,0.6504515,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-0.1963081,-60.63511;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;205.9204,-60.31974;Inherit;False;baseRGBA;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-172.7699,701.629;Inherit;False;47;baseRGBA;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;62;872.1509,1516.348;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;63;1112.151,1468.346;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;64;1264.951,1460.347;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;1904.951,1441.147;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;67;1636.153,1330.748;Inherit;False;Property;_AmbientColor;_AmbientColor;12;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;2232.049,1481.561;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;1720.296,2275.86;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;1945.896,2325.459;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;2112.625,2325.547;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;86;2389.426,2184.747;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;2118.225,2016.747;Inherit;False;74;colLit;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;88;2057.425,2115.146;Inherit;False;Property;_FogColor;_FogColor;17;0;Create;True;0;0;0;True;0;False;0,0,0,0;0.1607838,0.4078426,0.5764706,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;2599.026,2175.146;Inherit;False;finalC;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;78;1540.251,2231.679;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1537.122,2349.626;Inherit;False;Property;_FogStart;_FogStart;15;0;Create;True;0;0;0;True;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;1536.625,2441.546;Inherit;False;Property;_FogEnd;_FogEnd;16;0;Create;True;0;0;0;True;0;False;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;1715.825,2475.147;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;77;1136.235,2367.433;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;95;1209.98,2095.931;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;76;949.5966,2096.162;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;97;986.2758,769.3115;Inherit;False;74;colLit;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;38;623.4476,1254.505;Inherit;True;Property;_NormalMap;Normal Map;7;0;Create;True;0;0;0;True;0;False;-1;None;2a4827b5fba4cd5409f10d76507efc0c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;61;648.951,1519.548;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;96;1348.055,678.3452;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Curtains;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;1;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.668;True;True;0;True;Transparent;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;362.0454,486.2083;Inherit;False;89;finalC;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;1498.492,1850.164;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;2542.458,1461.81;Inherit;False;colLit;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;71;1656.351,1645.359;Inherit;True;Property;_LightMap;_LightMap;14;1;[HDR];Create;True;0;0;0;True;0;False;-1;None;3fe467185e6e60b4aa4c6f1c92384922;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;73;2281.947,1746.202;Inherit;False;47;baseRGBA;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;1720.552,1518.547;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;98;1439.674,1483.923;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;1243.751,1559.547;Inherit;False;Property;_LightPower;_LightPower;10;0;Create;True;0;0;0;False;0;False;0;-0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;99;2045.635,1576.111;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;2;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;100;1793.712,1858.735;Inherit;False;Property;_LightPowertEX;_LightPowertEX;11;0;Create;True;0;0;0;False;0;False;0;2.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;69;1446.552,1592.348;Inherit;False;Property;_LightColor;_LightColor;13;1;[HDR];Create;True;0;0;0;True;0;False;0,0,0,0;5.216476,5.067434,4.705474,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;10;0;7;2
WireConnection;10;1;9;0
WireConnection;11;0;10;0
WireConnection;20;0;22;1
WireConnection;20;1;21;0
WireConnection;25;0;24;0
WireConnection;23;0;26;1
WireConnection;23;1;25;0
WireConnection;27;0;20;0
WireConnection;27;1;23;0
WireConnection;28;0;35;0
WireConnection;28;1;34;0
WireConnection;28;2;29;0
WireConnection;28;3;27;0
WireConnection;3;0;2;2
WireConnection;3;1;8;0
WireConnection;3;4;28;0
WireConnection;8;0;4;0
WireConnection;32;0;28;0
WireConnection;32;1;1;1
WireConnection;16;0;15;0
WireConnection;16;1;18;0
WireConnection;15;0;13;1
WireConnection;15;1;14;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;34;0;16;0
WireConnection;35;1;11;0
WireConnection;49;0;58;0
WireConnection;56;0;54;0
WireConnection;58;0;75;0
WireConnection;58;1;39;1
WireConnection;58;2;51;0
WireConnection;48;0;39;1
WireConnection;48;1;56;3
WireConnection;45;0;37;0
WireConnection;45;1;46;0
WireConnection;47;0;45;0
WireConnection;62;0;61;0
WireConnection;63;0;62;0
WireConnection;63;1;38;0
WireConnection;64;0;63;0
WireConnection;68;0;67;0
WireConnection;68;1;70;0
WireConnection;72;0;68;0
WireConnection;72;1;99;0
WireConnection;72;2;73;0
WireConnection;80;0;78;0
WireConnection;80;1;79;0
WireConnection;81;0;80;0
WireConnection;81;1;84;0
WireConnection;85;0;81;0
WireConnection;86;0;87;0
WireConnection;86;1;88;0
WireConnection;86;2;85;0
WireConnection;89;0;86;0
WireConnection;78;0;95;0
WireConnection;78;1;77;0
WireConnection;84;0;83;0
WireConnection;84;1;79;0
WireConnection;95;0;76;0
WireConnection;96;2;49;0
WireConnection;96;11;3;0
WireConnection;74;0;72;0
WireConnection;70;0;69;0
WireConnection;70;1;98;0
WireConnection;98;0;64;0
WireConnection;98;1;65;0
WireConnection;99;0;71;0
WireConnection;99;1;100;0
ASEEND*/
//CHKSM=EB0E1B0891917DC8E8E6D0369C9D7A641ECA5529