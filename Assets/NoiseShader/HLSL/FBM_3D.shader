Shader "_Custom/FBM_3D"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _XSpeed("X Speed", Float) = 0.2
        _YSpeed("Y Speed", Float) = 1
        _FloatingSpeed("Floating Speed", Float) = 1
        _ColorSpeed("Color Speed", Float) = 1

        [Space]
        [IntRange]_FractalSteps("Fractal Steps", Range(1, 2)) = 2
        _FractalScale("Fractal Scale", Range(0.5, 3)) = 2
        _FractalPower("Fractal Power", Range(0, 1)) = 0.5

        [Space]
        [Enum(Off,0, One,1, Two,2)] _FractalMode("Fractal Mode", int) = 1
        _Offset_1("Offset 1", Vector) = (0.0, 0.0, 5.2, 1.3)
        _Power_1("Power 1", Range(0.1, 4)) = 2

        [Space]
        _Offset_2("Offset 2", Vector) = (1.7, 9.2, 8.3, 2.8)
        _Power_2("Power 2", Range(0.1, 4)) = 2
    }
        CGINCLUDE

#include "UnityCG.cginc"
#include "SimplexNoise3D.hlsl"

    sampler2D _MainTex;
    float4 _MainTex_ST;
    float _XSpeed, _YSpeed;
    float _FloatingSpeed, _ColorSpeed;
    float _FractalSteps, _FractalScale, _FractalPower;
    int _FractalMode;
    float4 _Offset_1, _Offset_2;
    float _Power_1, _Power_2;

    v2f_img vert(appdata_base v)
    {
        v2f_img o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
        return o;
    }

    float pattern(float3 p)
    {
        float3 result = p;
        if (_FractalMode >= 1)
        {
            float3 q = float3(snoise(result + _Offset_1.xyy),
                              snoise(result + _Offset_1.yzz),
                              snoise(result + _Offset_1.zww));

            result = p + _Power_1 * q;
        }
        if (_FractalMode >= 2)
        {
            float3 r = float3(snoise(result + _Offset_2.xyy),
                              snoise(result + _Offset_2.yzz),
                              snoise(result + _Offset_2.zww));

            result = p + _Power_2 * r;
        }
        return snoise(result);
    }

    float4 frag(v2f_img i) : SV_Target
    {
        float2 uv = i.uv + float2(_XSpeed, _YSpeed) * _Time.x;

        float3 o = 0.5;
        float s = 1.0;
        float w = 0.25;

        for (int i = 0; i < _FractalSteps; i++)
        {
            float3 coord = float3(uv * s, _Time.x * _FloatingSpeed);
            float3 period = float3(s, s, 1.0) * 2.0;
            o += pattern(coord) * w;

            s *= _FractalScale;
            w *= _FractalPower;
        }

        float y = 0.5 + 0.5 * sin(_ColorSpeed * _Time.x);
        float4 color = tex2D(_MainTex, float2(2 * o.x - 0.5, y));
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
