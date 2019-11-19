Shader "_Custom/DissolveSurf" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_BurnRamp("Burn Ramp (RGB)", 2D) = "white" {}

		[Space]
		_DissolveValue(" Dissolve Value", Range(0.0, 1.0)) = 0
		_BurnSize("Burn Size", Range(0.0, 1.0)) = 0.15
		_BurnColor("Burn Color", Color) = (1,1,1,1)
		_EmissionAmount("Emission amount", float) = 2.0
	}
		SubShader{
			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}
			LOD 200
			Cull Off
			CGPROGRAM
			#pragma surface surf Lambert alpha
			#pragma target 3.0

			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _BurnRamp;

			float _DissolveValue;
			float _BurnSize;
			fixed4 _BurnColor;
			float _EmissionAmount;

			struct Input 
			{
				float2 uv_MainTex;
			};


			void surf(Input IN, inout SurfaceOutput o) 
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				half luminance = _DissolveValue - tex2D(_NoiseTex, IN.uv_MainTex).rgb;
				clip(luminance);

				if (_DissolveValue > 0)
				{
					o.Emission = tex2D(_BurnRamp, float2(luminance * (1 / _BurnSize), 0)) * _BurnColor * _EmissionAmount;
				}

				o.Albedo = c.rgb;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}