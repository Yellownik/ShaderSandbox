Shader "Unlit/SimpleCloudParticle"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MaskTex("_MaskTex", 2D) = "white" {}

		[Space]
		_Speed_1("_Speed_1", Vector) = (0, 0.1, 0, 0)
		_Speed_2("_Speed_2", Vector) = (-0.02, 0.03, 0, 0)
		_Speed_3("_Speed_3", Vector) = (0, 0.05, 0, 0)
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
				sampler2D _MaskTex;

				float4 _Speed_1, _Speed_2, _Speed_3;
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
					fixed4 mask = tex2D(_MaskTex, i.uv);
					float2 offset = i.randomStable.xy;
					float2 speedScale = _Time.x + i.randomStable.zw;

					fixed4 col1 = tex2D(_MainTex, offset + i.uv       + speedScale * _Speed_1.xy);
					fixed4 col2 = tex2D(_MainTex, offset + i.uv * 0.5 + speedScale * _Speed_2.xy);
					fixed4 col3 = tex2D(_MainTex, offset + i.uv * 0.2 + speedScale * _Speed_3.xy);

					fixed res = saturate(col1 * col2 * col3 * mask * _ColorScale).r;
					return i.color * fixed4(1, 1, 1, res);
				}
				ENDCG
			}
		}
}
