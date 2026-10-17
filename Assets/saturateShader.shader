Shader "Custom/LambertAndNormalDebug_URP"
{
    Properties
    {
        _BaseColor ("Yüzey Rengi", Color) = (1, 1, 1, 1)
        [Toggle(_DEBUG_NORMALS)] _DebugNormals ("Normal Debugging Modunu Aç", Float) = 0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _DEBUG_NORMALS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float3 normalWS     : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                
                // Normal vektörünü Object Space'ten World Space'e dönüştür
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Vertex aşamasından gelen normali birim vektör yapmak için normalize et (N)
                float3 N = normalize(input.normalWS);

                #if defined(_DEBUG_NORMALS)
                    // Normal Debugging: [-1, 1] aralığını [0, 1] renk uzayına eşle
                    return half4(N * 0.5 + 0.5, 1.0);
                #else
                    // Sahnedeki ana yönsel ışık (Directional Light) yönünü al (L)
                    Light mainLight = GetMainLight();
                    float3 L = normalize(mainLight.direction);

                    // Lambert Işık Modeli: saturate(dot(N, L))
                    float NdotL = saturate(dot(N, L));

                    // Temel difüz aydınlatma: Albedo * Işık Rengi * NdotL
                    half3 diffuse = _BaseColor.rgb * mainLight.color * NdotL;

                    return half4(diffuse, 1.0);
                #endif
            }
            ENDHLSL
        }
    }
}