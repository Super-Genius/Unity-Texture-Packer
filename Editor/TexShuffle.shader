Shader "Hidden/TexShuffle"
{
    
    Properties
    {
        //channels red = 0, green = 1, blue = 2, alpha = 3
        _Slot0Tex("R Slot source texture", 2D) = "white"{}
        _Slot0Channel("R Slot channel ", float) = 0

        _Slot1Tex ("G Slot source texture", 2D) = "white"{}
        _Slot1Channel("G Slot Channel", float) = 0

        _Slot2Tex("B Slot source texture", 2D) = "white"{}
        _Slot2Channel("B Slot channel", float) = 0

        _Slot3Tex("A Slot source texture", 2D) = "white"{}
        _Slot3Channel("A Slot channel", float) = 0

        _Inverts("Invert states", Vector) = (0,0,0,0)

    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma editor_sync_compilation

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;      
            };
            
            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _Slot0Tex, _Slot1Tex, _Slot2Tex, _Slot3Tex;
            float _Slot0Channel, _Slot1Channel, _Slot2Channel, _Slot3Channel;
            float4 _Inverts;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = v.uv;
                return o;
            }
            float GetChannel(sampler2D tex, float channelNum, float2 coord)
            {
                float value = 0;
                if (channelNum == 0) { value = tex2D(tex, coord).r; }
                else if (channelNum == 1) { value = tex2D(tex, coord).g; }
                else if (channelNum == 2) { value = tex2D(tex, coord).b; }
                else if (channelNum == 3) { value = tex2D(tex, coord).a; }
                else if (channelNum == 4) {
                    float4 col = tex2D(tex, coord);
                    value = 0.299 * col.r + 0.587 * col.g + 0.114 * col.b;
                }
                
                return value;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = float4(0,0,0,0);

                col.r = abs(_Inverts.r - GetChannel(_Slot0Tex, _Slot0Channel, i.uv));
                col.g = abs(_Inverts.g - GetChannel(_Slot1Tex, _Slot1Channel, i.uv));
                col.b = abs(_Inverts.b - GetChannel(_Slot2Tex, _Slot2Channel, i.uv));
                col.a = abs(_Inverts.a - GetChannel(_Slot3Tex, _Slot3Channel, i.uv));

                return col;
            }
            ENDCG
        }
    }
}
