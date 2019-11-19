Shader "Unlit/Portal"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Speed("_Speed", Vector) = (0, -1, 0, 0)
		_ColorScale("_ColorScale", Range(1, 20)) = 10
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				float _IsAlpha;
				float4 _Speed;
				float _ColorScale;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col1 = tex2D(_MainTex, i.uv);
					fixed4 col2 = tex2D(_MainTex, i.uv + _Time.x * _Speed.xy);

					float res = saturate(col1 * col2 * _ColorScale).r;
					return fixed4(0, 1, 0, res);
				}
				ENDCG
			}
		}
}
