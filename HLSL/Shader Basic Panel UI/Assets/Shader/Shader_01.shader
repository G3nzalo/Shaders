Shader "Unlit/Test2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Red ("Red Amount", Range(0,4)) = 0.0
        _Green ("Gren Amount", Range(0,4)) = 0.0
        _Blue ("Blue Amount", Range(0,4)) = 0.0

        _PosXIlumination ("Position X ilumination", Range(0.8,2)) = 0.0
        _PosYIlumination ("Position Y ilumination ", Range(-2.0,7.47)) = 0.0

        _PosX ("Position X ", Range(0.0,1)) = 0.0
        _PosY ("Position Y  ", Range(0.0,1)) = 0.0

        _AmountIterpolation ("Interpolation Amount", Range(0,4)) = 0.0

        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
       _Vector ("Vector", Vector) = (1,1,1,1)    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float4 _ColorA;
            float4 _ColorB;
            float _Pi;
            float4 _Vector;
            float _Red; 
            float _Blue; 
            float _Green;
            float _PosX;
            float _PosY;
            float _PosXIlumination;
            float _PosYIlumination;
            float _AmountIterpolation;


            const float PI = 3.1415926535897932384;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed2 SetPoint (in float x, float y , v2f _i)
            {
              fixed2 _point = fixed2(x, y) - _i.uv;
              return _point;
            }

            float SetRadio(in fixed2 _point)
            {
             float _radio = length(_point * pow(_point.x, _point.y));
             return _radio;
            }

            float SetAngle(in float x , float y)
            { 
                float _angle = atan2(x,y);
                return _angle;
            }

            fixed4 Ilumination(in float radio ,float r , float g , float  b)
            {
               fixed4 _ilumination = fixed4(radio + r , radio + g , radio + b , 1.0);
               return _ilumination;
            }

            fixed4 DrawRadio(in float radio)
            {
               fixed4 _drawRadio = fixed4(radio , radio , radio  , 1.0);
               return _drawRadio;
            }
            
            fixed4 DrawAngle(in float angle , float r , float g , float  b)
            {
               fixed4 _drawAngle = fixed4(angle + r , angle + g , angle + b , 1.0);
               return _drawAngle;
            }

            fixed4 Interpolation(in fixed4 a , fixed4 b , fixed4 amount)
            {
                fixed4 mix = smoothstep(a , b , amount);
                return mix;
            }

            fixed4 Pulse(in fixed4 value , float time)
            {              
                if(sin(time) > 0.3)
                {
                    value[0] = 22.0;

                    time = sin(time * value[3]);   

                    value[2] = time * value[1];        
                    fixed4 _test = DrawRadio(time * sin(value[1]));

                    fixed4 _pulse2 = Interpolation (value * sin(value * 0.4), _test, sin(value[3]));
                    fixed4 _inter = Interpolation(_test,_pulse2 , cos(time));
                    return _pulse2;      
                }
                
                else
                {
                fixed4 _pulse = atan(value * time) * atan(sin((time * 2.0))) ;
                return _pulse;
                }
    
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_APPLY_FOG(i.fogCoord, col);
                float _time = _Time.z;
                fixed2 _pointIlumination = SetPoint(_PosXIlumination,_PosYIlumination,i);
                float _radio = SetRadio(_pointIlumination);
                fixed4 _iluminationArea = Ilumination(_radio, _Red, _Green, _Blue);

                fixed2 _pointForCircle = SetPoint(0.5,0.5,i); 
                float _radio2 = SetRadio(_pointForCircle);
                fixed4 _drawRadio = DrawRadio(_radio2);
                
                fixed2 _point = SetPoint(_PosX,_PosY,i);
                float _angle = SetAngle(_point.x , _point.y);

                fixed4 _drawAngle = DrawAngle(_angle , _ColorA.r, _ColorA.g, _ColorA.b);
                
                fixed4 interpolation = Interpolation(_drawAngle,_iluminationArea, _AmountIterpolation);
                fixed4 feedback = interpolation;
                fixed4 _drawAngle2 = _drawAngle;

                fixed4 fin = lerp(interpolation,feedback,_drawAngle);
               
               // fixed4 _pulse = Pulse(interpolation, _time);
                /*   
                 col = fixed4(r,r,r,1.0); //Visualizo solo el radio.
                 col = vec4(vec3(a),1.0); //Visualizo solo el angulo.
                 fixed4 f = fixed4(_angle , _angle ,_angle,1.0);
                */
            return frac(_time*0.1 + interpolation) *frac(interpolation * _time * 0.2 * sin(interpolation * _time) * sin(_time * 0.1 + i.uv.x)) + fin;
            }
            ENDCG
        }
    }
}
