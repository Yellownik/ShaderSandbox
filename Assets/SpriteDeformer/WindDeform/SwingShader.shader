Shader "Unlit/SwingShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" { }

        [Space]
        [Toggle(USE_NOISE)] _IsUseNoise("Is Use Noise", Float) = 0
        _SpeedX("Speed X", Range(0.001, 10)) = 1
        _Shift("Shift", Range(-2, 2)) = 0.3
        _Amplitude("Amplitude", Range(0, 2)) = 0.5
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
            
            #pragma shader_feature USE_NOISE
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

            float _SpeedX, _Shift, _Amplitude;

            float2 random2(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
            }

            float4 shift_vertex(float4 vertex, float2 uv)
            {
                fixed2 offset = 0;
                #ifdef USE_NOISE
                    float2 noise_uv = TRANSFORM_TEX(uv + _Time.y * float2(_SpeedX, 0), _NoiseTex);
                    offset = tex2Dlod(_NoiseTex, float4(noise_uv, 0, 0)).xy * 2 - 1;
                #else
                    offset = sin(_Time.y * float2(_SpeedX, 0));
                #endif

                float4 worldPosition = mul(unity_ObjectToWorld, vertex);
                worldPosition.x += (1 - uv.y) * (_Shift + offset.x * _Amplitude);
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
