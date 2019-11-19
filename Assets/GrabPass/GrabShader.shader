Shader "_Custom/GrabShader"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Color("_Color", Color) = (1, 1, 1, 1)

		_BumpMap("_BumpMap", 2D) = "bump" {}
		_Magnitude("_Magnitude", Range(0, 1)) = 0.05

	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		ZWrite On Lighting Off Cull Off Fog { Mode Off } Blend One Zero

		GrabPass { "_GrabTexture" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;
			sampler2D _MainTex;
			fixed4 _Color;

			sampler2D _BumpMap;
			float _Magnitude;

            struct vin
            {
                float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;

                float4 uvgrab : TEXCOORD1;
            };

            v2f vert (vin v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
				fixed4 mainColor = tex2D(_MainTex, i.texcoord);
				fixed4 bump = tex2D(_BumpMap, i.texcoord);
				fixed2 distortion = UnpackNormal(bump).rg;
				i.uvgrab.xy += distortion * _Magnitude;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
                return col * mainColor * _Color;
            }
            ENDCG
        }
    }
}
