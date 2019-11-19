Shader "Unlit/TunnelShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
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

            sampler2D _Mask;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mask = tex2D(_Mask, i.uv);

                fixed4 c = 1;
                float2 p = i.uv;
                p -= 0.5;
                c.w = length(p);
                c = tex2D(_MainTex, float2(0.2 / (c.w), atan2(p.y, p.x)) + float2(_Time.y, 0)) * (mask.r - 0.5) * mask.r;
                return c;
            }
            ENDCG
        }
    }
}
