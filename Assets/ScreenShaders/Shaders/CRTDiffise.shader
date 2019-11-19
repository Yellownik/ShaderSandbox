Shader "Hidden/CRTDiffise"
{
    Properties
    {
		[HideInInspector]
		_MainTex("Texture", 2D) = "white" {}
		_MaskTex ("_MaskTex", 2D) = "white" {}
		_MaskBlend("_MaskBlend", Range(0, 2)) = 0.5
		_MaskSize("_MaskSize", Float) = 1
	}
		SubShader
		{
			Pass
			{
				CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment frag

				#include "UnityCG.cginc"

				uniform sampler2D _MainTex;
				uniform sampler2D _MaskTex;

				fixed _MaskBlend;
				fixed _MaskSize;

				fixed4 frag (v2f_img i) : SV_Target
				{
					float4 base = tex2D(_MainTex, i.uv);
					float4 mask = tex2D(_MaskTex, i.uv * _MaskSize);

					return lerp(base, mask, _MaskBlend);
				}
				ENDCG
			}
    }
}
