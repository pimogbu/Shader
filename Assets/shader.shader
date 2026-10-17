Shader "Custom/URPVertexManipulationDemo"
{
    Properties
    {
        _WaveSpeed ("Wave Speed", Float) = 3.0
        _WaveFrequency ("Wave Frequency", Float) = 4.0
        _WaveAmplitude ("Wave Amplitude", Float) = 0.2
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes // Meshdata
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };
   
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            // SRP Batcher buffers
            CBUFFER_START(UnityPerMaterial)
                float _WaveSpeed;
                float _WaveFrequency;
                float _WaveAmplitude;
            CBUFFER_END

            // 2. Step (Vertex Shader)
            Varyings vert(Attributes input)
            {
                Varyings output;

                float wave = sin(_Time.y * _WaveSpeed + input.positionOS.x * _WaveFrequency) * _WaveAmplitude;
                input.positionOS.y += wave;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(input.uv.x, input.uv.y, 0.0, 1.0);
            }
            ENDHLSL
        }
    }
}