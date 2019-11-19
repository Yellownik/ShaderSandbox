Shader "_Custom/DissolveShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_BurnRamp("Burn Ramp", 2D) = "white" {}

		[Space]
		_DissolveValue("Dissolve Value", Range(0, 1)) = 1
		_BurnSize("Gradient Adjust", Range(0, 5)) = 2
	}
		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}
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
				sampler2D _NoiseTex;
				sampler2D _BurnRamp;
				float4 _MainTex_ST;

				float _DissolveValue;
				float _BurnSize;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 mainTex = tex2D(_MainTex, i.uv);
					fixed noise = tex2D(_NoiseTex, i.uv).r;

					fixed d = (2.0 * _DissolveValue - noise) - 1.0;
					fixed overOne = saturate(d * _BurnSize);

					fixed4 burn = tex2D(_BurnRamp, float2(overOne, 0.5));
					return saturate(mainTex * burn);
				}
				ENDCG
			}
		}
}
