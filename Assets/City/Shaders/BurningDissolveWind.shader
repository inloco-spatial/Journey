Shader "Custom/BurningDissolveWindSmoothGlowWithEmissionUVControl"
{
    Properties
    {
        _MainTex ("Diffuse Texture", 2D) = "white" {}
        _EmissiveTex ("Emissive Texture", 2D) = "black" {}
        _NoiseTex ("Noise Texture (for dissolve)", 2D) = "white" {}

        // Dissolve controls
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0
        _EdgeWidth ("Edge Width", Range(0.001, 0.2)) = 0.05
        _DissolveGlowColor ("Dissolve Edge Glow Color", Color) = (1, 0.5, 0.1, 1)
        _DissolveGlowStrength ("Dissolve Edge Glow Strength", Range(0,20)) = 5
        _DissolveDirection ("Dissolve Direction (1=bottom->top, -1=top->bottom)", Range(-1,1)) = 1

        // Emission
        _EmissiveColor ("Emissive Color", Color) = (1, 1, 1, 1)
        _EmissionStrength ("Emission Strength", Range(0,10)) = 1

        // Wind controls via UV region (single cutoff + invert toggle)
        _WindStrength ("Wind Strength", Range(0,1)) = 0.1
        _WindSpeed ("Wind Speed", Range(0,10)) = 2.0
        _WindNoiseScale ("Wind Noise Scale", Range(0.1,10)) = 1.0
        _WindUV_Scale ("Wind UV Scale", Float) = 1.0
        _WindUV_Attenuation ("Wind UV Attenuation", Float) = 1.0
        _WindUV_Influence ("Wind UV Influence", Float) = 1.0
        _WindRegionCutoff ("Wind Region Cutoff (y, 0->1)", Range(0,1)) = 0.2
        _WindRegionInvert ("Invert Region (0=bottom,1=top)", Range(0,1)) = 0
        // Vertical flutter control
        _WindVerticalStrength ("Wind Vertical Strength", Range(0,1)) = 0.1

        // Noise for dissolve edge
        _NoiseScale ("Noise UV Scale", Float) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        Cull Off

        Pass
        {
            Stencil { Ref 2 Comp Always Pass Replace }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _EmissiveTex;
            sampler2D _NoiseTex;

            float4 _DissolveGlowColor;
            float _DissolveGlowStrength;
            float _DissolveAmount;
            float _EdgeWidth;
            float _DissolveDirection;

            float4 _EmissiveColor;
            float _EmissionStrength;

            float _WindStrength;
            float _WindSpeed;
            float _WindNoiseScale;
            float _WindUV_Scale;
            float _WindUV_Attenuation;
            float _WindUV_Influence;
            float _WindRegionCutoff;
            float _WindRegionInvert;
            float _WindVerticalStrength;

            float _NoiseScale;

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float2 uv : TEXCOORD0; float4 vertex : SV_POSITION; float3 worldPos : TEXCOORD1; };

            float hash(float2 p) { return frac(sin(dot(p, float2(12.9898,78.233))) * 43758.5453); }
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));
                float2 u = f*f*(3-2*f);
                return lerp(a,b,u.x) + (c-a)*u.y*(1-u.x) + (d-b)*u.x*u.y;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Wind via UV region cutoff + invert
                float regionParam = (_WindRegionInvert > 0.5) ? (1 - v.uv.y) : v.uv.y;
                float region = saturate(regionParam / max(_WindRegionCutoff, 0.0001));
                float attenuation = pow(region, _WindUV_Attenuation);
                float influence = attenuation * _WindUV_Influence;

                float2 windUV = v.uv * _WindUV_Scale;
                float wfactor = noise(windUV * _WindNoiseScale + _Time.y * _WindSpeed) - 0.5;

                // Horizontal displacement
                float3 pos = v.vertex.xyz;
                float hOff = wfactor * _WindStrength * influence;
                pos.x += hOff;
                pos.z += hOff;

                // Vertical flutter (flapping) by height-based influence
                float vAtten = attenuation; // reuse region-based attenuation
                float vOff = wfactor * _WindVerticalStrength * vAtten;
                pos.y += vOff;

                o.vertex = UnityObjectToClipPos(float4(pos,1));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                fixed4 baseCol = tex2D(_MainTex, uv);
                fixed4 emissiveCol = tex2D(_EmissiveTex, uv);

                // Dissolve along UV.y, direction via slider
                float baseCoord = (_DissolveDirection > 0) ? uv.y : (1 - uv.y);
                baseCoord = saturate(baseCoord);
                float noiseVal = tex2D(_NoiseTex, uv * _NoiseScale).r;
                float dissolveValue = baseCoord + (noiseVal - 0.5) * 0.2;

                float alpha = 1 - smoothstep(_DissolveAmount - _EdgeWidth, _DissolveAmount + _EdgeWidth, dissolveValue);
                float edge = pow(saturate(1 - abs(dissolveValue - _DissolveAmount) / _EdgeWidth), 2);
                fixed4 glow = _DissolveGlowColor * edge * _DissolveGlowStrength;

                fixed4 finalCol = baseCol;
                finalCol.rgb += glow.rgb;
                finalCol.rgb += emissiveCol.rgb * _EmissiveColor.rgb * _EmissionStrength;
                finalCol.a *= alpha;

                return finalCol;
            }
            ENDHLSL
        }
    }
}