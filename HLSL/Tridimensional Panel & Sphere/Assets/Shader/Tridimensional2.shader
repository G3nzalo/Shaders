Shader "Unlit/Test2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _posX ("Position X ", Float) = 0.0
        _posY ("Position Y  ",  Float) = 0.0
        _Size ("Size",  Float) = 0.0
        _Vertices ("Vertices", Float) = 0.0
        _BlendMode ("BlendMode", Range(1,25)) = 1
        _Seed("Seed",  Float) = 0.0
    }
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
            float _PosX;
            float _PosY;
            float _Vertices;
            float _Size;
            float _Seed;
            int _BlendMode;
            fixed2 _point;


            const float PI = 3.1415926535897932384;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed2 SetPoint (in float x, float y , fixed2 uv)
            {
                fixed2 _point = fixed2(x, y) - uv;
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

            float DrawPoly(float2 uv,float2 p, float s, float dif,int N,float a)
            {
                // Remap the space to -1. to 1.
                float2 st = p - uv ;
                // Angle and radius from the current pixel
                float a2 = atan2(st.x,st.y)+a;
                float r = PI*2. /float(N);
                float d = cos(floor(0.5+a2/r)*r-a2)*length(st);
                float e = 1.0 - smoothstep(s,s+dif,d);
                
                return e;
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

            float Rdm(float p)
            {
                p*=1234.56;
                p = frac(p * 0.1031);
                p *= p + 33.33;
                return frac(2.0*p*p);
            }

            float Mapr(float _value,float _low2,float _high2) 
            {
                float val = _low2 + (_high2 - _low2) * (_value - 0.0) / (1.0 - 0);
                //float val = 0.1;
                return val;
            }
            float blendSoftLight(float base, float blend)
            {
                return 
                (blend<0.5)?
                (2.0*base*blend+base*base*(1.0-2.0*blend))
                :
                (sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend));
            }
            fixed3 blendSoftLight(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendSoftLight(base.r,blend.r),blendSoftLight(base.g,blend.g),blendSoftLight(base.b,blend.b));
            }
            fixed3 blendSoftLight(fixed3 base, fixed3 blend, float opacity)
            {
                return (blendSoftLight(base, blend) * opacity + base * (1.0 - opacity));
            }
            //ADD : 
            float blendAdd(float base, float blend) 
            {
                return min(base+blend,1.0);
            }
            fixed3 blendAdd(fixed3 base, fixed3 blend)
            {
                return min(base+blend,fixed3(1.0,1.0,1.0));
            }
            fixed3 blendAdd(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendAdd(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendAverage(fixed3 base, fixed3 blend) 
            {
                return (base+blend)/2.0;
            }
            fixed3 blendAverage(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendAverage(base, blend) * opacity + base * (1.0 - opacity));
            } 
            float blendColorBurn(float base, float blend) 
            {
                return (blend==0.0)?blend:max((1.0-((1.0-base)/blend)),0.0);
            }
            fixed3 blendColorBurn(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendColorBurn(base.r,blend.r),blendColorBurn(base.g,blend.g),blendColorBurn(base.b,blend.b));
            }
            fixed3 blendColorBurn(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendColorBurn(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendColorDodge(float base, float blend) 
            {
                return (blend==1.0)?blend:min(base/(1.0-blend),1.0);
            }
            fixed3 blendColorDodge(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendColorDodge(base.r,blend.r),blendColorDodge(base.g,blend.g),blendColorDodge(base.b,blend.b));
            }
            fixed3 blendColorDodge(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendColorDodge(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendDarken(float base, float blend) 
            {
                return min(blend,base);
            }
            fixed3 blendDarken(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendDarken(base.r,blend.r),blendDarken(base.g,blend.g),blendDarken(base.b,blend.b));
            }
            fixed3 blendDarken(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendDarken(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendDifference(fixed3 base, fixed3 blend) 
            {
                return abs(base-blend);
            }
            fixed3 blendDifference(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendDifference(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendExclusion(fixed3 base, fixed3 blend) 
            {
                return base+blend-2.0*base*blend;
            }
            fixed3 blendExclusion(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendExclusion(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendLighten(float base, float blend) 
            {
                return max(blend,base);
            }
            fixed3 blendLighten(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendLighten(base.r,blend.r),blendLighten(base.g,blend.g),blendLighten(base.b,blend.b));
            }
            fixed3 blendLighten(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendLighten(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendLinearBurn(float base, float blend) 
            {
                // Note : Same implementation as BlendSubtractf
                return max(base+blend-1.0,0.0);
            }
            fixed3 blendLinearBurn(fixed3 base, fixed3 blend) 
            {
                // Note : Same implementation as BlendSubtract
                return max(base+blend-fixed3(1.0,1.0,1.0),fixed3(0.0,0.0,0.0));
            }
            fixed3 blendLinearBurn(fixed3 base, fixed3 blend, float opacity)
            {
                return (blendLinearBurn(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendLinearDodge(float base, float blend) 
            {
                // Note : Same implementation as BlendAddf
                return min(base+blend,1.0);
            }
            fixed3 blendLinearDodge(fixed3 base, fixed3 blend) 
            {
                // Note : Same implementation as BlendAdd
                return min(base+blend,fixed3(1.0,1.0,1.0));
            }
            fixed3 blendLinearDodge(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendLinearDodge(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendLinearLight(float base, float blend) 
            {
                return blend<0.5?blendLinearBurn(base,(2.0*blend)):blendLinearDodge(base,(2.0*(blend-0.5)));
            }
            fixed3 blendLinearLight(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendLinearLight(base.r,blend.r),blendLinearLight(base.g,blend.g),blendLinearLight(base.b,blend.b));
            }
            fixed3 blendLinearLight(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendLinearLight(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendMultiply(fixed3 base, fixed3 blend) 
            {
                return base*blend;
            }
            fixed3 blendMultiply(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendMultiply(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendNegation(fixed3 base, fixed3 blend) 
            {
                return fixed3(1.0,1.0,1.0)-abs(fixed3(1.0,1.0,1.0)-base-blend);
            }
            fixed3 blendNegation(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendNegation(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendNormal(fixed3 base, fixed3 blend) 
            {
                return blend;
            }
            fixed3 blendNormal(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendNormal(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendOverlay(float base, float blend) 
            {
                return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
            }
            fixed3 blendOverlay(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
            }
            fixed3 blendOverlay(fixed3 base, fixed3 blend, float opacity)
            {
                return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendPhoenix(fixed3 base, fixed3 blend) 
            {
                return min(base,blend)-max(base,blend)+fixed3(1.0,1.0,1.0);
            }
            fixed3 blendPhoenix(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendPhoenix(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendPinLight(float base, float blend) 
            {
                return (blend<0.5)?blendDarken(base,(2.0*blend)):blendLighten(base,(2.0*(blend-0.5)));
            }
            fixed3 blendPinLight(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendPinLight(base.r,blend.r),blendPinLight(base.g,blend.g),blendPinLight(base.b,blend.b));
            }
            fixed3 blendPinLight(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendPinLight(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendReflect(float base, float blend) 
            {
                return (blend==1.0)?blend:min(base*base/(1.0-blend),1.0);
            }
            fixed3 blendReflect(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendReflect(base.r,blend.r),blendReflect(base.g,blend.g),blendReflect(base.b,blend.b));
            }
            fixed3 blendReflect(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendReflect(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendScreen(float base, float blend) 
            {
                return 1.0-((1.0-base)*(1.0-blend));
            }
            fixed3 blendScreen(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b));
            }
            fixed3 blendScreen(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendScreen(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendSubstract(float base, float blend) 
            {
                return max(base+blend-1.0,0.0);
            }
            fixed3 blendSubstract(fixed3 base, fixed3 blend) 
            {
                return max(base+blend-fixed3(1.0,1.0,1.0),fixed3(0.0,0.0,0.0));
            }
            fixed3 blendSubstract(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendSubstract(base, blend) * opacity + blend * (1.0 - opacity));
            }
            float blendVividLight(float base, float blend) 
            {
                return (blend<0.5)?blendColorBurn(base,(2.0*blend)):blendColorDodge(base,(2.0*(blend-0.5)));
            }
            fixed3 blendVividLight(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendVividLight(base.r,blend.r),blendVividLight(base.g,blend.g),blendVividLight(base.b,blend.b));
            }
            fixed3 blendVividLight(fixed3 base, fixed3 blend, float opacity)
            {
                return (blendVividLight(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendHardLight(fixed3 base, fixed3 blend) 
            {
                return blendOverlay(blend,base);
            }
            fixed3 blendHardLight(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendHardLight(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendGlow(fixed3 base, fixed3 blend) 
            {
                return blendReflect(blend,base);
            }
            fixed3 blendGlow(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendGlow(base, blend) * opacity + base * (1.0 - opacity));
            }
            float blendHardMix(float base, float blend) 
            {
                return (blendVividLight(base,blend)<0.5)?0.0:1.0;
            }
            fixed3 blendHardMix(fixed3 base, fixed3 blend) 
            {
                return fixed3(blendHardMix(base.r,blend.r),blendHardMix(base.g,blend.g),blendHardMix(base.b,blend.b));
            }
            fixed3 blendHardMix(fixed3 base, fixed3 blend, float opacity) 
            {
                return (blendHardMix(base, blend) * opacity + base * (1.0 - opacity));
            }
            fixed3 blendMode( int mode, fixed3 base, fixed3 blend )
            {
                if( mode == 1) return blendAdd( base, blend );
                if( mode == 2) return blendAverage( base, blend );
                if( mode == 3) return blendColorBurn( base, blend );
                if( mode == 4) return blendColorDodge( base, blend );
                if( mode == 5) return blendDarken( base, blend );
                if( mode == 6) return blendDifference( base, blend );
                if( mode == 7) return blendExclusion( base, blend );
                if( mode == 8) return blendGlow( base, blend );
                if( mode == 9) return blendHardLight( base, blend );
                if( mode ==10) return blendHardMix( base, blend );
                if( mode ==11) return blendLighten( base, blend );
                if( mode ==12) return blendLinearBurn( base, blend );
                if( mode ==13) return blendLinearDodge( base, blend );
                if( mode ==14) return blendLinearLight( base, blend );
                if( mode ==15) return blendMultiply( base, blend );
                if( mode ==16) return blendNegation( base, blend );
                if( mode ==17) return blendNormal( base, blend );
                if( mode ==18) return blendOverlay( base, blend );
                if( mode ==19) return blendPhoenix( base, blend );
                if( mode ==20) return blendPinLight( base, blend );
                if( mode ==21) return blendReflect( base, blend );
                if( mode ==22) return blendScreen( base, blend );
                if( mode ==23) return blendSoftLight( base, blend );
                if( mode ==24) return blendSubstract( base, blend );
                if( mode ==25) return blendVividLight( base, blend );

                else return blendAdd( base, blend );
            }
            
            fixed3 blendMode( int mode, fixed3 base, fixed3 blend ,float opacity)
            {
                if( mode == 1 ) return blendAdd( base, blend ,opacity);
                if( mode == 2 ) return blendAverage( base, blend ,opacity);
                if( mode == 3 ) return blendColorBurn( base, blend ,opacity);
                if( mode == 4 ) return blendColorDodge( base, blend ,opacity);
                if( mode == 5 ) return blendDarken( base, blend ,opacity);
                if( mode == 6 ) return blendDifference( base, blend ,opacity);
                if( mode == 7 ) return blendExclusion( base, blend,opacity );
                if( mode == 8 ) return blendGlow( base, blend ,opacity);
                if( mode == 9 ) return blendHardLight( base, blend ,opacity);
                if( mode == 10) return blendHardMix( base, blend,opacity );
                if( mode == 11) return blendLighten( base, blend ,opacity);
                if( mode == 12) return blendLinearBurn( base, blend ,opacity);
                if( mode == 13) return blendLinearDodge( base, blend,opacity );
                if( mode == 14) return blendLinearLight( base, blend ,opacity);
                if( mode == 15) return blendMultiply( base, blend ,opacity);
                if( mode == 16) return blendNegation( base, blend ,opacity);
                if( mode == 17) return blendNormal( base, blend ,opacity);
                if( mode == 18) return blendOverlay( base, blend ,opacity);
                if( mode == 19) return blendPhoenix( base, blend ,opacity);
                if( mode == 20) return blendPinLight( base, blend ,opacity);
                if( mode == 21) return blendReflect( base, blend ,opacity);
                if( mode == 22) return blendScreen( base, blend ,opacity);
                if( mode == 23) return blendSoftLight( base, blend ,opacity);
                if( mode == 24) return blendSubstract( base, blend ,opacity);
                if( mode == 25) return blendVividLight( base, blend ,opacity);
            }

            float2x2 Scale(fixed2 _scale){
                return float2x2(_scale.x,0.0,
                            0.0,_scale.y);
            }
            
            float2x2 Rotate2d(float _angle){
                return float2x2(cos(_angle),-sin(_angle),
                            sin(_angle),cos(_angle));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_APPLY_FOG(i.fogCoord, col);
                float _time = _Time.z;  
                float fix = _ScreenParams.x / _ScreenParams.y ;
                i.uv.x *= fix;

                const int cantidad = 20;
                fixed3 formaFinal = fixed3(0.2,0.0,0.01);

                fixed2 uv2 = i.uv;
                float anterior = 0;
                fixed2 uvAnterior = fixed2(0.0,0.0);
                for (int j = 0 ; j < cantidad ; j++)
                {
                    float index = float(j) * PI * 3.2 / float(cantidad);

                    fixed2 movimiento = fixed2(sin(_time+index) + 2.2, cos(_time + index * i.uv.x));
                    uv2 = frac(i.uv * (float(j) + 1.0)+ movimiento);
                    float2 position = fixed2(0.5 * fix - 0.2, 0.2);
                    _point = position - uv2 ;
                    float radio = length(_point * 0.8 * sin(_time));

                    fixed3 color1 = fixed3(5.8,1.3,0.0);
                    fixed3 color2 = fixed3(1.0,5.0,4.0);

                    float indice_color = (float(j) + 2.0) / float(cantidad * sin(_time * 0.2));
                    fixed3 colorFinal = lerp(color1 , color2 ,indice_color);

                    formaFinal += smoothstep(0.93,0.99,1.0-radio)* colorFinal;
                    uvAnterior = uv2;

                }

               return fixed4(formaFinal,1.0);
            }
            ENDCG

            
        }

    }

    
}
