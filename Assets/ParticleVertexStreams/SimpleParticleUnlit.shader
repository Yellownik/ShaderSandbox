Shader "Unlit/SimpleParticleUnlit"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent"}
        LOD 100
        Blend One One
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;

                float freq = 5;
                float ampl = 4;
                float sineOffset = sin(_Time.y * freq) * ampl;
                float agePercent = v.uv.z;
                float3 vertOffset = float3(0, sineOffset * agePercent, 0);
                v.vertex.xyz += vertOffset * (1 + v.uv.w);

               /* float sineFrequency = 5.0;
                float sineAmplitude = 4.0;
                float sineOffset = sin(_Time.y * sineFrequency) * sineAmplitude;
                float agePercent = v.uv.z;
                float3 vertexOffset = float3(0, sineOffset * agePercent, 0);
                v.vertex.xyz += vertexOffset;*/

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.z = v.uv.z;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                float agePercent = i.uv.z;
                float4 red = float4(1, 0, 0, 1);

                col = lerp(col, red*col.a, agePercent);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
