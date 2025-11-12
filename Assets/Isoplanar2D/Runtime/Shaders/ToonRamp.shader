Shader "Isoplanar/ToonRamp"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex   ("Main Tex", 2D) = "white" {}
        _RampTex   ("Ramp (1D 256x1)", 2D) = "white" {}
        _RampStrength ("Ramp Strength", Range(0,1)) = 1
        _ReceiveShadows ("Receive Shadows (approx.)", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);       SAMPLER(sampler_MainTex);
            TEXTURE2D(_RampTex);       SAMPLER(sampler_RampTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
                float  _RampStrength;
                float  _ReceiveShadows;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float2 uv          : TEXCOORD1;
                float3 posWS       : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                VertexPositionInputs posInputs = GetVertexPositionInputs(v.positionOS.xyz);
                VertexNormalInputs norInputs   = GetVertexNormalInputs(v.normalOS);

                o.positionHCS = posInputs.positionCS;
                o.normalWS    = norInputs.normalWS;
                o.uv          = TRANSFORM_TEX(v.uv, _MainTex);
                o.posWS       = posInputs.positionWS;
                UNITY_TRANSFER_FOG(o, o.positionHCS);
                return o;
            }

            float SampleRamp(float ndotl)
            {
                float u = saturate(ndotl);
                float4 col = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(u, 0.5));
                return Luminance(col.rgb); // use ramp luminance as band factor
            }

            float MainShadow(float3 posWS)
            {
                #if defined(_MAIN_LIGHT_SHADOWS)
                    Light mainLight = GetMainLight(TransformWorldToShadowCoord(posWS));
                    return mainLight.shadowAttenuation;
                #else
                    return 1.0;
                #endif
            }

            half4 frag (Varyings i) : SV_Target
            {
                float3 N = SafeNormalize(i.normalWS);
                Light mainLight = GetMainLight();
                float  ndotl = saturate(dot(N, -mainLight.direction));

                float4 baseTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                float3 albedo = baseTex.rgb * _BaseColor.rgb;

                // Ramp factor
                float rampBand = SampleRamp(ndotl);
                float shade = lerp(1.0, rampBand, _RampStrength);

                // Shadows (approx.)
                float shadow = lerp(1.0, MainShadow(i.posWS), _ReceiveShadows);

                float3 color = albedo * shade * shadow;
                half4 outCol = half4(color, _BaseColor.a * baseTex.a);

                UNITY_APPLY_FOG(i.fogCoord, outCol);
                return outCol;
            }
            ENDHLSL
        }
    }
}

