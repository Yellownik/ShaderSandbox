Shader "Unlit/TexDoodleShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NoiseTex("NoiseTex", 2D) = "white" {}
        _MaskTex ("MaskTex", 2D) = "white" {}
        [KeywordEnum(Smooth, Random)] Topology("Topology", Float) = 0
        _Intensity("Intensity", Range(-5, 5)) = 0.1
        _NoiseSpeed("Noise Speed", Range(0.1, 10)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend One OneMinusSrcAlpha
        Cull off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile TOPOLOGY_SMOOTH TOPOLOGY_RANDOM

            #include "UnityCG.cginc"
            #define PI 3.14159265359

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

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            float _Intensity, _NoiseSpeed;

            #ifdef TOPOLOGY_SMOOTH
                static const float TopologyLerp = 0;
            #else
                static const float TopologyLerp = 1;
            #endif

            float2 random2(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
            }

            float4 shift_vertex(float4 vertex, float2 uv)
            {
                float4 worldPosition = mul(unity_ObjectToWorld, vertex);
                float2 noiseUV = TRANSFORM_TEX(uv, _NoiseTex);
                noiseUV = lerp(noiseUV, random2(noiseUV), TopologyLerp) + _Time.x * _NoiseSpeed;

                float4 positionOffset = tex2Dlod(_NoiseTex, float4(noiseUV, 0, 0));
                float mask = tex2Dlod(_MaskTex, float4(uv, 0, 0)).r;
                positionOffset *= mask * mask;

                worldPosition.xy += (positionOffset.xy - 0.5) * _Intensity;
                return mul(unity_WorldToObject, worldPosition);
            }

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex = shift_vertex(v.vertex, v.uv);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
