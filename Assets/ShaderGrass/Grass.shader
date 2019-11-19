Shader "Roystan/Grass"
{
	Properties
	{
		_ObjPos("Obj Pos", Vector) = (0, 0, 0, 0)
		_Radius("HoleRadius", Range(0.1, 5)) = 2
		_Al("Al", Range(0.1, 1)) = 1

		[Space]
		_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
		_WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
		_WindStrength("Wind Strength", Float) = 1

		[Header(Shading)]
		_TopColor("Top Color", Color) = (1,1,1,1)
		_BottomColor("Bottom Color", Color) = (1,1,1,1)
		_TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
		_BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2
		_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1

		[Space]
		_BladeWidth("Blade Width", Float) = 0.05
		_BladeWidthRandom("Blade Width Random", Float) = 0.02
		_BladeHeight("Blade Height", Float) = 0.05
		_BladeHeightRandom("Blade Height Random", Float) = 0.02
		_BladeForward("Blade Forward", Float) = 0.38
		_BladeCurve("Blade Curvature", Range(1, 4)) = 2
	}

		CGINCLUDE
#include "UnityCG.cginc"
#include "Autolight.cginc"
#include "Shaders/CustomTessellation.cginc"

#define BLADE_SEGMENTS 30

		uniform float4 _ObjPos;
		float _Radius;
		float _Al;

		sampler2D _WindDistortionMap;
		float4 _WindDistortionMap_ST;
		float2 _WindFrequency;
		float _WindStrength;

		float _BendRotationRandom;
		float _BladeWidth;
		float _BladeWidthRandom;
		float _BladeHeight;
		float _BladeHeightRandom;
		float _BladeForward;
		float _BladeCurve;
			
		struct geometryOutput
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
		};

		geometryOutput VertexOutput(float3 pos, float2 uv)
		{
			geometryOutput o;
			o.pos = UnityObjectToClipPos(pos);
			o.worldPos = pos;
			o.uv = uv;
			return o;
		}

		float rand(float3 co)
		{
			return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
		}

		float3x3 AngleAxis3x3(float angle, float3 axis)
		{
			float c, s;
			sincos(angle, s, c);

			float t = 1 - c;
			float x = axis.x;
			float y = axis.y;
			float z = axis.z;

			return float3x3(
				t * x * x + c, t * x * y - s * z, t * x * z + s * y,
				t * x * y + s * z, t * y * y + c, t * y * z - s * x,
				t * x * z - s * y, t * y * z + s * x, t * z * z + c
				);
		}

		geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
		{
			float3 tangentPoint = float3(width, forward, height);
			float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
			return VertexOutput(localPosition, uv);
		}

		[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
		void geo(point vertexOutput IN[1] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
		{
			float3 pos = IN[0].vertex;
			float3 vNormal = IN[0].normal;
			float4 vTangent = IN[0].tangent;

			float relativeDist = length(_ObjPos - pos) / _Radius;

			float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;
			float3x3 tangentToLocal = float3x3
				(
					vTangent.x, vBinormal.x, vNormal.x,
					vTangent.y, vBinormal.y, vNormal.y,
					vTangent.z, vBinormal.z, vNormal.z
					);

			float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
			float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;

			/*if (relativeDist < 1)
				windSample = windSample * (relativeDist);*/

			float3 wind = normalize(float3(windSample.x, windSample.y, 0));
			float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);

			float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
			float bendRotationRandom = _BendRotationRandom;
			/*if (relativeDist < 1)
				bendRotationRandom = lerp(1, bendRotationRandom, relativeDist);*/

			float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * bendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
			float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
			float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);

			float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
			float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
			float forward = rand(pos.yyz) * _BladeForward;

			float bladeCurve = _BladeCurve;
			/*if (relativeDist < 1)
			{
				forward = lerp(2 * forward, forward, relativeDist) * sin(_Time.y + sin(_Time.y) + (pos.x + pos.z) * (pos.x - pos.z));
				bladeCurve = lerp(2 * bladeCurve, bladeCurve, relativeDist);// *(0.5 + sin(_Time.y + sin(_Time.y) + (pos.x + pos.z) * (pos.x - pos.z)));
			}*/


			for (int i = 0; i < BLADE_SEGMENTS; i++)
			{
				float t = i / (float)BLADE_SEGMENTS;
				float th = t;
				if (relativeDist < 1)
				{
					//th = 0.5 - 2 * (t - 0.5) * (t - 0.5);
					th *= relativeDist + 0.5;
				}

				float segmentHeight = height * th;
				float segmentWidth = width * (1 - t);
				float segmentForward = pow(t, bladeCurve) * forward;

				float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;
				triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
				triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
			}
			float lastPointHeight = height;
			if (relativeDist < 1)
				lastPointHeight = 0;

			triStream.Append(GenerateGrassVertex(pos, 0, lastPointHeight, forward, float2(0.5, 1), transformationMatrix));
		}
			ENDCG

			SubShader
		{
			Cull Off

				Pass
			{
				Tags
				{
					"Queue" = "Transparent"
					"RenderType" = "Transparent"
					"LightMode" = "ForwardBase"
				}

				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geo
				#pragma target 4.6
				#pragma hull hull
				#pragma domain domain

				#include "Lighting.cginc"

				float4 _TopColor;
				float4 _BottomColor;
				float _TranslucentGain;

				float4 frag(geometryOutput i, fixed facing : VFACE) : SV_Target
				{
					float4 c = lerp(_BottomColor, _TopColor, i.uv.y);
					float1 dist = length(_ObjPos - i.worldPos) / _Radius;

					if (dist < 1)
					{
						dist = pow(dist, 1);
						c = c * dist + i.worldPos.y * (1 - dist) * float4(1, 1, 0, 1);
						c.a = 0.2 + 0.2 * lerp(dist, 1 - dist, dist);
					}

					return c;
				}
				ENDCG
			}
		}
}