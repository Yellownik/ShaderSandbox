Shader "Hidden/BWDiffise"
{
    Properties
    {
		[HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
		_bwBlend("Black & White Blend", Range(0, 1)) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment frag
				#include "UnityCG.cginc"

				uniform sampler2D _MainTex;
				float _bwBlend;

				fixed4 frag (v2f_img i) : SV_Target
				{
					float4 c = tex2D(_MainTex, i.uv);
					float lum = c.r * 0.3 + c.g * 0.59 + c.b * 0.11;

					return float4(lerp(c.rgb, lum, _bwBlend), c.a);
				}
				ENDCG
			}
    }
}
