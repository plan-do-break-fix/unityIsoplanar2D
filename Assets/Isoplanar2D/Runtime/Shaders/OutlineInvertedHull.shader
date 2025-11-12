Shader "Isoplanar/OutlineInvertedHull"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Thickness    ("Thickness (object space)", Range(0,0.05)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1" }
        Cull Front        // draw back faces only (inverted hull)
        ZWrite On
        ZTest LEqual

        Pass
        {
            Name "Outline"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _OutlineColor;
                float  _Thickness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                float3 posOS = v.positionOS.xyz + v.normalOS * _Thickness;
                o.positionHCS = TransformObjectToHClip(float4(posOS,1));
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                return (half4)_OutlineColor;
            }
            ENDHLSL
        }
    }
}

