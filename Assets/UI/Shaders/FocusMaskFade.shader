/*  Assets/Shaders/FocusMaskFade.shader  */
Shader "Custom/FocusMaskFade"
{
    Properties
    {
        _Fade  ("Fade 0‑1", Range(0,1)) = 1
        _Color ("Mask Color (RGB, A=1)", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "Queue"="Overlay+10" "RenderType"="Transparent" }
        Cull Off ZWrite Off ZTest Always

        // Закрашиваем ВСЁ, кроме того, где Stencil == 1
        Stencil
        {
            Ref 1
            Comp NotEqual
        }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed   _Fade;
            fixed4  _Color;

            fixed4 frag (v2f_img i) : SV_Target
            {
                return fixed4(_Color.rgb, _Color.a * _Fade);
            }
            ENDCG
        }
    }
    FallBack Off
}
