Shader "Roystan/Toon/Water"
{
    Properties
    {	
		_DepthGradientShallow("_DepthGradientShallow", Color) = (0.325, 0.807, 0.971, 0.725)
		_DepthGradientDeep("_DepthGradientDeep", Color) = (0.086, 0.407, 1, 0.749)
		_DepthMaxDistance("_DepthMaxDistance", Float) = 1

		[Space]
		_SurfaceNoise("_SerfaceNoise", 2D) = "white" {}
		_SurfaceNoiseCutoff("_SurfaceNoiseCutoff", Range(0, 1)) = 0.777

		[Space]
		_FoamColor("_FoamColor", Color) = (1, 1, 1, 1)
		_FoamMaxDistance("_FoamMaxDistance", Range(0.001, 1)) = 0.4
		_FoamMinDistance("_FoamMinDistance", Range(0.001, 1)) = 0.04

		[Space]
		_SurfaceNoiseScroll("_SurfaceNoiseScroll", Vector) = (0.03, 0.03, 0, 0)
		_SurfaceDistortion("_SurfaceDistortion", 2D) = "white" {}
		_SurfaceDistortionAmount("_SurfaceDistortionAmount", Range(0, 1)) = 0.27
    }
    SubShader
    {
		Tags
		{
			"Queue" = "Transparent"
		}

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			#define SMOOTHSTEP_AA 0.01
			
			float4 alphaBlend(float4 top, float4 bottom)
			{
				float3 color = top.rgb * top.a + bottom.rgb * (1 - top.a);
				float alpha = top.a + bottom.a * (1 - top.a);

				return float4(color, alpha);
			}

            struct appdata
            {
                float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 screenPosition : TEXCOORD2;

				float2 noiseUV : TEXCOORD0;
				float2 distortUV : TEXCOORD1;

				float3 viewNormal : NORMAL;
            };

			sampler2D _SurfaceNoise;
			float4 _SurfaceNoise_ST;

			float2 _SurfaceNoiseScroll;
			sampler2D _SurfaceDistortion;
			float4 _SurfaceDistortion_ST;
			float _SurfaceDistortionAmount;


            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPosition = ComputeScreenPos(o.vertex);

				o.noiseUV = TRANSFORM_TEX(v.uv, _SurfaceNoise);
				o.noiseUV += _SurfaceNoiseScroll * _Time.y;
				o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);

				o.viewNormal = COMPUTE_VIEW_NORMAL;

                return o;
            }

			float4 _DepthGradientShallow;
			float4 _DepthGradientDeep;
			float _DepthMaxDistance;

			sampler2D _CameraDepthTexture;
			float _SurfaceNoiseCutoff;

			float4 _FoamColor;
			float _FoamMaxDistance;
			float _FoamMinDistance;

			sampler2D _CameraNormalsTexture;

            float4 frag (v2f i) : SV_Target
            {
				float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
				float existingDepthLinear = LinearEyeDepth(existingDepth01);
				float depthDifference = existingDepthLinear - i.screenPosition.w;

				float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
				float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);

				float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
				float3 normalDot = saturate(dot(existingNormal, i.viewNormal));

				float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
				float foamDepthDifference01 = saturate(depthDifference / foamDistance);
				float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;

				float2 distortionSample = tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1;
				distortionSample *= _SurfaceDistortionAmount;

				float surfaceNoiseSample = tex2D(_SurfaceNoise, i.noiseUV + distortionSample).r;
				//float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;
				float surfaceNoise = smoothstep(surfaceNoiseCutoff - SMOOTHSTEP_AA, surfaceNoiseCutoff + SMOOTHSTEP_AA, surfaceNoiseSample);
				float4 surfaceNoiseColor = _FoamColor;
				surfaceNoiseColor.a *= surfaceNoise;

				return alphaBlend(surfaceNoiseColor, waterColor);
            }
            ENDCG
        }
    }
}