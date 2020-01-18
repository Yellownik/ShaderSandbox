Shader "Unlit/TunnelDeformer"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _DeformerTex("Deformer", 2D) = "Grey" {}
        _MaskTex("Deformer Mask", 2D) = "White"{}

        _Intensity("Deformer Intensity", Range(-1, 1)) = 0
        _Speed("Deform Speed", Range(-5, 5)) = 1
        _MaskClip("Mask Clip", Range(-2, 2)) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
            LOD 100
            Cull off
            //Zwrite off
            Blend One OneMinusSrcAlpha

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
                    float2 uvDeformer : TEXCOORD1;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float2 uvDeformer : TEXCOORD1;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                sampler2D _DeformerTex;
                float4 _DeformerTex_ST;

                sampler2D _MaskTex;

                float _Intensity;
                float _Speed;
                float _MaskClip;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.uvDeformer = v.uvDeformer;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    /*float2 uvDeformer = i.uvDeformer * _DeformerTex_ST.xy;
                    float2 deformer = tex2D(_DeformerTex, uvDeformer + _Time.y * _Speed);
                    float2 uvOffset = deformer * _Intensity * 0.5;

                    fixed4 mask1 = tex2D(_MaskTex, i.uv);

                    fixed4 c = 1;
                    float2 p = i.uv;
                    p -= 0.5;
                    c.w = length(p);
                    c = tex2D(_MainTex, float2(0.2 / (c.w), atan2(p.y, p.x)) + float2(_Time.y, 0)) * (mask1.r - 0.5) * mask1.r;
                    uvOffset = c.xy;

                    fixed4 mask = tex2D(_MaskTex, i.uv);
                    fixed4 col = tex2D(_MainTex, i.uv + uvOffset * mask.r * _Intensity * normalize(i.uv - float2(0.5, 0.5)));
                    return col * col.a;*/
                    


                    fixed4 mask = tex2D(_MaskTex, i.uv);

                    fixed4 c = 1;
                    float2 p = i.uv;
                    p -= 0.5;
                    c.w = length(p);
                    //c = tex2D(_DeformerTex, float2(0.2 / (c.w), atan2(p.y, p.x)) + float2(_Time.y, 0) * _Speed) * (mask.r - _MaskClip) * mask.r;
                    c = tex2D(_DeformerTex, float2(0.2 / (c.w), atan2(p.y, p.x)) + float2(_Time.y, 0) * _Speed) * (mask.r - _MaskClip);
                    //return c;

                    float2 uvOffset = c.xy;

                    //fixed4 mask = tex2D(_MaskTex, i.uv);
                    fixed4 col = tex2D(_MainTex, i.uv + uvOffset * mask.r * _Intensity * normalize(i.uv - float2(0.5, 0.5)));
                    return col * col.a;
                }
                ENDCG
            }
        }
}
