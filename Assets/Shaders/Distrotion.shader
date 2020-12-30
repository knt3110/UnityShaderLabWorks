Shader "Unlit/Water"
{
    Properties
    {
        _DistortionTex("Distortion Texture(RG)", 2D) = "grey" {}
        _DistortionPower("Distortion Power", Range(0, 1)) = 0
        _Speed("Speed", Float) = 1.0
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

        Cull Back
        ZWrite On
        ZTest LEqual
        ColorMask RGB

        GrabPass { "_GrabPassTexture" }

        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex  : POSITION;
                float4 uv  : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex  : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
            };

            sampler2D _DistortionTex;
            half4 _DistortionTex_ST;
            sampler2D _GrabPassTexture;
            half _DistortionPower;
            float _Speed;
            fixed4 _Color;
           

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DistortionTex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half2 uv = half2(i.grabPos.x / i.grabPos.w, i.grabPos.y / i.grabPos.w);
                half2 distortion = tex2D(_DistortionTex, i.uv + _Time.x * _Speed).rg - 0.5;
                distortion *= _DistortionPower;
                uv = uv + distortion;
                return tex2D(_GrabPassTexture, uv) * _Color;
            }
            ENDCG
        }
    }
}
