Shader "Unlit/RandomDoodleShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity("Deformer Intensity", Range(-1, 1)) = 0.1
        _NoiseSnap("_NoiseSnap", Range(0.1, 10)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend One OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            float _Intensity, _NoiseSnap;

            inline float snap(float x, float snap)
            {
                return snap * floor(x / snap);
            }

            float2 random2(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
            }

            float2 vertexOffset(float2 pos)
            {
                float2 time = snap(_Time.y + pos.x * 100, _NoiseSnap);
                float2 noise = random2(pos + time) * _Intensity;
                float2 offset = lerp(0, noise, 0.5 + 0.5 * sin(-0.5 * PI + 2 * PI * frac((_Time.y + pos.x * 100) / _NoiseSnap)));
                return offset;
            }

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.xy += vertexOffset(v.vertex.xy);

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
