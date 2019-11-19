Shader "_Custom/DissolveShader_1"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_BurnRamp("Burn Ramp", 2D) = "white" {}

		[Space]
		_DissolveValue("Dissolve Value", Range(0, 1)) = 1
		_BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
		_BurnColor("Burn Color", Color) = (1,1,1,1)
		_BurnEdgeEmission("Burn Edge Emission", float) = 2.0
	}
		SubShader
		{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Cull Off

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
				float _BurnEdgeEmission;
				float4 _BurnColor;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 original = tex2D(_MainTex, i.uv);
					fixed4 noise = tex2D(_NoiseTex, i.uv);
					float invertedGreyscale = 1.0 - dot(noise.rgb, float3(0.3, 0.59, 0.11));
					float luminance = _DissolveValue - noise.rgb;
					clip(luminance);

					if (_DissolveValue < 1)
						original += tex2D(_BurnRamp, float2(luminance * (1 / (_BurnSize)), 0.0)) * _BurnColor *_BurnEdgeEmission;

					return original;
				}
				ENDCG
			}
		}
}
