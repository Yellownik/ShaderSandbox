Shader "_Custom/FBM_2D"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        [IntRange]_FractalSteps("Fractal Steps", Range(1, 3)) = 2
        _FractalScale("Fractal Scale", Range(0.5, 3)) = 2
        _FractalPower("Fractal Power", Range(0, 1)) = 0.5

        [Space]
        [Enum(Off,0, One,1, Two,2)] _FractalMode("Fractal Mode", int) = 1
        _Offset_1("Offset 1", Vector) = (0.0, 0.0, 5.2, 1.3)
        _Power_1("Power 1", Range(1, 6)) = 2

        [Space]
        _Offset_2("Offset 2", Vector) = (1.7, 9.2, 8.3, 2.8)
        _Power_2("Power 2", Range(1, 6)) = 2
    }
        CGINCLUDE

#include "UnityCG.cginc"
#include "SimplexNoise2D.hlsl"

        sampler2D _MainTex;
        float _FractalSteps, _FractalScale, _FractalPower;
        int _FractalMode;

        float4 _Offset_1, _Offset_2;
        float _Power_1, _Power_2;

        v2f_img vert(appdata_base v)
        {
            v2f_img o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord.xy;
            return o;
        }

        float pattern(float2 p)
        {
            float2 result = p;
            if (_FractalMode >= 1)
            {
                float2 q = float2(snoise(p + _Offset_1.xy),
                                  snoise(p + _Offset_1.zw));

                result = p + _Power_1 * q;
            }
            if (_FractalMode >= 2)
            {
                float2 r = float2(snoise(result + _Offset_2.xy),
                                  snoise(result + _Offset_2.zw));

                result = p + _Power_2 * r;
            }
            return snoise(result);
        }

        float4 frag(v2f_img i) : SV_Target
        {
            float2 uv = i.uv * 4.0 + float2(0.2, 1) * _Time.x;

            float3 o = 0.5;
            float s = 1.0;
            float w = 0.25;

            for (int i = 0; i < _FractalSteps; i++)
            {
                float3 coord = float3(uv * s, _Time.x);
                float3 period = float3(s, s, 1.0) * 2.0;
                o += pattern(coord) * w;

                s *= _FractalScale;
                w *= _FractalPower;
            }
            float4 color = tex2D(_MainTex, float2(2*o.x - 0.5, 0));
            return color;
        }

            ENDCG
            SubShader
        {
            Pass
            {
                CGPROGRAM
                #pragma target 3.0
                #pragma vertex vert
                #pragma fragment frag
                ENDCG
            }
        }
}
