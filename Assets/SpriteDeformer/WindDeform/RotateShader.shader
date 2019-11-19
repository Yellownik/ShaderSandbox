Shader "Unlit/RotateShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}

        _ZFrequency("Z Frequency", Range(0.0, 1)) = 0.37
        _ZShift("Z Shift", Range(-1, 1)) = 0.1
        _ZAmplitude("Z Amplitude", Range(0, 2)) = 0.1

        [Space]
        _YFrequency("Y Frequency", Range(0.0, 1)) = 0.37
        _YShift("Y Shift", Range(-1, 1)) = 0.0
        _YAmplitude("Y Amplitude", Range(0, 2)) = 0.3
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

            float _ZFrequency, _ZShift, _ZAmplitude;
            float _YFrequency, _YShift, _YAmplitude;

            float4 shift_vertex(float4 vertex, float2 uv)
            {
                float x = _Time.y * float2(_ZFrequency, 0);
                float angle = cos(x) * (0.7 * sin(x) + 0.3 * sin(_Time.y));

                float s, c;
                sincos(angle * _ZAmplitude + _ZShift, s, c);
                float4x4 RotationZ = float4x4(c, -s, 0, 0,
                                              s, c, 0, 0,
                                              0, 0, 1, 0,
                                              0, 0, 0, 1);

                x = _Time.y * float2(_YFrequency, 0);
                angle = sin(x) * cos(_Time.y);
                sincos(angle * _YAmplitude + _YShift, s, c);
                float4x4 RotationY = float4x4(c, 0, s, 0,
                                              0, 1, 0, 0,
                                             -s, 0, c, 0,
                                              0, 0, 0, 1);

                vertex = mul(RotationY, vertex);
                vertex = mul(RotationZ, vertex);
                return vertex;
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
