Shader "Unlit/GrassWindShader"
{
    Properties
    {
        _SpeedX("SpeedX", Float) = 0.5
        _Intensity("Intensity", Float) = 0.05
        _MaxY("Max Y", Range(0, 1)) = 0.25
        _MinY("Min Y", Range(0, 1)) = 0.10

        _MainTex("Main Tex", 2D) = "white" { }
        _NoiseTex("Noise", 2D) = "white" { }
        [Toggle(SHOW_LIMITS)] _IsShowLimits("Show Limits", Float) = 0
    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" }
            Blend SrcAlpha OneMinusSrcAlpha
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                #pragma shader_feature SHOW_LIMITS

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float2 noise_uv : TEXCOORD1;
                    float4 vertex : SV_POSITION;
                };

                float4 _Color;

                sampler2D _MainTex;
                float4 _MainTex_ST;

                sampler2D _NoiseTex;
                float4 _NoiseTex_ST;

                float _SpeedX, _Intensity;
                float _MinY, _MaxY;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.noise_uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed2 noiseSample = (tex2D(_NoiseTex, i.noise_uv + _Time.x * float2(_SpeedX, 0)).xy * 2 - 1) * _Intensity;
                    noiseSample.x *= saturate((i.uv.y - _MinY) / (_MaxY - _MinY));
                    noiseSample.y = 0;
                    fixed4 col = tex2D(_MainTex, frac(i.uv + noiseSample));

                    #ifdef SHOW_LIMITS
                        col += float4(step(i.uv.y, _MaxY), step(_MinY, i.uv.y), 0, 0.5);
                    #endif

                    return col;
                }
                ENDCG
            }
        }
}
