Shader "Unlit/RadialShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _DetailTex("_DetailTex", 2D) = "white" {}
        _Intencity ("_Intencity", Range(-2,2)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            float4 _MainTex_ST;

            sampler2D _DetailTex;

            float _Intencity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 fourDirectionalUVMoving(v2f i)
            {
                fixed2 offset = fixed2(0, 0);
                float scale = 2.0;
                i.uv = -abs(i.uv - float2(0.5, 0.5));
                i.uv *= scale;
                i.uv += float2(1, 1) * _Time.x * 10;
                i.uv = frac(i.uv);
                fixed4 col = tex2D(_MainTex, i.uv + offset * _Intencity);
                return col;
            }

            fixed4 distanceColor(v2f i)
            {
                i.uv -= fixed2(0.5, 0.5);
                i.uv -= normalize(i.uv) + ((_Time.x * 10));
                i.uv = frac(i.uv);

                float scale = 1.5;
                i.uv = -abs(i.uv - float2(0.5, 0.5));
                i.uv *= scale;
                i.uv = frac(i.uv);
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }

            fixed4 distanceColor1(v2f i)
            {
                float scale = 2.0;
                i.uv = abs(i.uv - float2(0.5, 0.5));
                i.uv *= scale;
                i.uv = frac(i.uv);

                i.uv -= normalize(i.uv) + (_Time.x * 10);
                i.uv = frac(i.uv);
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //return distanceColor(i);
                //return distanceColor1(i);
                //return fourDirectionalUVMoving(i);

                return lerp(distanceColor1(i), fourDirectionalUVMoving(i), 0.5 + 0.25 * sin(_Time.y));
            }


            ENDCG
        }
    }
}
