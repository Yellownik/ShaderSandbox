Shader "Unlit/PortalParticle"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Speed("_Speed", Vector) = (0, 0.1, 0, 0)
		_ColorScale("_ColorScale", Range(1, 20)) = 10
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
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
					fixed4 color : COLOR;
					float2 uv : TEXCOORD0;
					float4 randomStable : TEXCOORD1;
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 uv : TEXCOORD0;
					float4 randomStable : TEXCOORD1;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				float4 _Speed;
				float _ColorScale;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.randomStable = v.randomStable;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float2 offset = float2(0, i.randomStable.y);
					float2 speedScale = _Time.x + i.randomStable.zw;

					fixed4 col1 = tex2D(_MainTex, i.uv);
					fixed4 col2 = tex2D(_MainTex, offset + i.uv + speedScale * _Speed.xy);

					float res = saturate(col1 * col2 * _ColorScale).r;
					return i.color * fixed4(0, 1, 0, res);
				}
				ENDCG
			}
		}
}
