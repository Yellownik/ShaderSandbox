Shader "Custom/Emission"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_PartTex("_PartTex", 2D) = "white" {}
		_Color("_Color", Color) = (1, 0, 0, 1)
		_TimeScale("_TimeScale", Range(0, 2)) = 0.05
	}
		SubShader
		{
			Pass
			{
				Tags
				{
					"RenderQueue" = "Transparent"
				}
				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D_float _CameraDepthTexture;
				sampler2D _MainTex;
				sampler2D _PartTex;

				float4 _Color;
				float _TimeScale;

				struct vertexInput
				{
					float4 vertex : POSITION;
					float3 texCoord : TEXCOORD0;
					float4 color : COLOR;
				};

				struct vertexOutput
				{
					float4 pos : SV_POSITION;
					float3 texCoord : TEXCOORD0;
					float linearDepth : TEXCOORD1;
					float4 screenPos : TEXCOORD2;
					float4 color : COLOR;
				};

				vertexOutput vert(vertexInput input)
				{
					vertexOutput output;
					output.pos = UnityObjectToClipPos(input.vertex);
					output.texCoord = input.texCoord;

					output.screenPos = ComputeScreenPos(output.pos);
					output.linearDepth = -(UnityObjectToViewPos(input.vertex).z * _ProjectionParams.w);

					output.color = input.color;

					return output;
				}

				float4 frag(vertexOutput input) : COLOR
				{
					float4 c = tex2D(_MainTex, input.texCoord);
					float4 p = tex2D(_PartTex, input.texCoord);

					c = lerp(c * 0.2, c, input.color.a); // try to comment

					c.a *= 0.05 * input.color.a * (0.2 + p.r);
					return c;
				}

				ENDCG
			}
		}
}