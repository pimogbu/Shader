Shader "Custom/circleShader"
{
    Properties
    {
        [Header(Surface Options)]
        [MainColor] _ColorTint("Tint", Color) = (1, 1, 1, 1)
        [MainTexture] _ColorMap("Color", 2D) = "white" {}
        _Speed("Fall Speed", Float) = 0.5
        _Radius("Circle Radius", Range(0.05, 0.5)) = 0.25
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass

        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_ColorMap);
            SAMPLER(sampler_ColorMap); 

            CBUFFER_START(UnityPerMaterial)
                half4 _ColorTint;
                float4 _ColorMap_ST;
                float _Speed;
                float _Radius;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                IN.positionOS.y += sin(IN.positionOS.x * 4.0 + _Time.y) * 0.2;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _ColorMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 movingUV = IN.uv;
                // movingUV.y = frac(movingUV.y + _Time.y * _Speed);
                float dist = length(movingUV - 0.5);
                float circle = step(_Radius, dist);
                return half4(1, circle, circle, 1.0) * _ColorTint; 
            }
            ENDHLSL 
        }
    }
}