Shader "Custom/Bloom"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _GlowMap;

			float4 frag(v2f_img input) : COLOR
			{
				float4 glow = tex2D(_GlowMap, input.uv);;
                float4 mainTex = tex2D(_MainTex, input.uv);

				float4 t = smoothstep(0, 1, _Time.x + glow.r);

				// Variant 1
				return lerp(mainTex * glow.r, mainTex, t);

				// Variant 2
				if (1 - t.r > 0)
					return float4(glow.r, 0, 0, 1);
				else
					return lerp(mainTex * glow.r, mainTex, t); 

				// Variant 3
				return lerp(float4(glow.r * 10, 0, 0, 1), lerp(mainTex * glow.r, mainTex, t), t);
			}

			ENDCG
		}
	}
}