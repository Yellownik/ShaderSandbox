Shader "Hidden/DistortionDiffuse"
{
    Properties
    {
		[HideInInspector]
		_MainTex("Texture", 2D) = "white" {}
		_DisplacementTex("_DisplacementTex", 2D) = "white" {}
		_Strength("_Strength", Range(-0.5, 0.5)) = 0.1
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
				uniform sampler2D _DisplacementTex;

				fixed _Strength;

				fixed4 frag (v2f_img i) : SV_Target
				{
					float2 n = tex2D(_DisplacementTex, i.uv);
					float2 d = 2 * n - 1;

					i.uv += d * _Strength;
					i.uv = saturate(i.uv);

					float4 base = tex2D(_MainTex, i.uv);

					return base;
				}
				ENDCG
			}
    }
}
