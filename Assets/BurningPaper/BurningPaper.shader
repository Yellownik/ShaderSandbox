Shader "_Custom/BurningPaper"
{
    Properties
    {
		_MainTex("Main Tex", 2D) = "white" {}
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_BurnRamp("Burn Ramp", 2D) = "white" {}

		[Space]
		_DissolveValue("Dissolve Value", Range(0, 1)) = 1
		_BurnSize("Burn Size", Range(0, 2)) = 2
    }
    SubShader
    {
		Tags 
		{ 
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
			 #pragma enable_d3d11_debug_symbols
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
			sampler2D _NoiseTex;
			sampler2D _BurnRamp;
			float4 _MainTex_ST;

			float _DissolveValue;
			float _BurnSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				fixed4 noiseVal = tex2D(_NoiseTex, i.uv);

				fixed luminance = _DissolveValue + noiseVal.r - 0.5;
				clip(luminance);

				if (_DissolveValue < 1)
				{
					float x = luminance * (1 / _BurnSize);
					fixed4 burn = tex2D(_BurnRamp, float2(clamp(x, 0, 1), 0.0));
					mainTex *= burn;
				}

				return mainTex;
            }
            ENDCG
        }
    }
}
