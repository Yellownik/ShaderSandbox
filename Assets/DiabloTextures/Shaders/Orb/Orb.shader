﻿Shader "Unlit/Orb"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DetailRGB("DetilRGB", 2D) = "white" {}
		_DetailAlpha("_DetailAlpha", 2D) = "white" {}
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

				sampler2D _MainTex, _DetailRGB, _DetailAlpha;
				float4 _MainTex_ST;

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
					fixed4 main = tex2D(_MainTex, i.uv);
					main.a = (main.r + main.g + main.b);

					fixed4 rgb = tex2D(_DetailRGB, i.uv + _Time.x * _Speed.xy);
					rgb.a = tex2D(_DetailAlpha, i.uv + _Time.x * _Speed.xy).r;

					fixed4 res = saturate(main * rgb * _ColorScale);
					return res;
				}
				ENDCG
			}
		}
}
