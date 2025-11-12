Shader "Isoplanar/MatcapToon"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex   ("Main Tex", 2D) = "white" {}
        _Matcap    ("Matcap (square)", 2D) = "gray" {}
        _MatcapStrength ("Matcap Strength", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);  SAMPLER(sampler_MainTex);
            TEXTURE2D(_Matcap);   SAMPLER(sampler_Matcap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
                float  _MatcapStrength;
            CBUFFER_END

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float3 normalVS    : TEXCOORD0;
                float2 uv          : TEXCOORD1;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                VertexPositionInputs posInputs = GetVertexPositionInputs(v.positionOS.xyz);
                VertexNormalInputs norInputs   = GetVertexNormalInputs(v.normalOS);

                o.positionHCS = posInputs.positionCS;
                // view-space normal for matcap UVs
                float3 normalVS = TransformWorldToViewDir(norInputs.normalWS, true);
                o.normalVS = normalize(normalVS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 mUV = i.normalVS.xy * 0.5 + 0.5;
                float4 mat = SAMPLE_TEXTURE2D(_Matcap, sampler_Matcap, mUV);
                float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                float3 baseCol = baseTex.rgb * _BaseColor.rgb;
                float3 result  = lerp(baseCol, baseCol * mat.rgb, _MatcapStrength);

                return half4(result, _BaseColor.a * baseTex.a);
            }
            ENDHLSL
        }
    }
}

