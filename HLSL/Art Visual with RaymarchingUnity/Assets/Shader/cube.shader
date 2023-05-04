Shader "Raymarching/test"
{

Properties
{
    [Header(PBS)]
    _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    _Metallic("Metallic", Range(0.0, 1.0)) = 0.5
    _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5 

    _Red("Red", float) = 1.0
    _Green("Green", float) = 1.0
    _Blue("Blue", float) = 1.0



    [Header(Pass)]
    [Enum(UnityEngine.Rendering.CullMode)] _Cull("Culling", Int) = 2
    [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc("Blend Src", Float) = 5 
    [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst("Blend Dst", Float) = 10
    [Toggle][KeyEnum(Off, On)] _ZWrite("ZWrite", Float) = 1

    [Header(Raymarching)]
    _Loop("Loop", Range(1, 100)) = 30
    _MinDistance("Minimum Distance", Range(0.001, 0.1)) = 0.01
    _DistanceMultiplier("Distance Multiplier", Range(0.001, 2.0)) = 1.0
    _ShadowLoop("Shadow Loop", Range(1, 100)) = 30
    _ShadowMinDistance("Shadow Minimum Distance", Range(0.001, 0.1)) = 0.01
    _ShadowExtraBias("Shadow Extra Bias", Range(0.0, 0.1)) = 0.0
    [PowerSlider(10.0)] _NormalDelta("NormalDelta", Range(0.00001, 0.1)) = 0.0001

    [Header(Fractal)]
    [PowerSlider(1.0)] _Scale("Escala", Range(1, 2)) = 1.5
    [PowerSlider(1.0)] _RotAngle("Angulo Rotacion", Range(-360, 360)) = 60
    [PowerSlider(1.0)] _RotX("Rotacion X", Range(-1, 0.30)) = 1
    [PowerSlider(1.0)] _RotY("Rotacion Y", Range(0, 0.14)) = 1
    [PowerSlider(1.0)] _RotZ("Rotacion Z", Range(0.17, 5)) = 1
    [PowerSlider(1.0)] _Iterations("Iterations", Range(1, 10)) = 1

}

SubShader
{

Tags
{
    "RenderType" = "Opaque"
    "Queue" = "Geometry"
    "DisableBatching" = "True"
}

Cull [_Cull]

CGINCLUDE

#define OBJECT_SCALE

#define OBJECT_SHAPE_CUBE

#define CAMERA_INSIDE_OBJECT

#define USE_RAYMARCHING_DEPTH

#define USE_CAMERA_DEPTH_TEXTURE

#define DISABLE_VIEW_CULLING

#define SPHERICAL_HARMONICS_PER_PIXEL

#define DISTANCE_FUNCTION DistanceFunction
#define PostEffectOutput SurfaceOutputStandard
#define POST_EFFECT PostEffect

#include "Assets/uRaymarching/Runtime/Shaders/Include/Legacy/Common.cginc"

float3 col , Color;
float _Scale, _RotAngle, _RotX, _RotY, _RotZ , _ColorFixed , _Red,_Green,_Blue;
int _Iterations;


float2x2 rot(float a) {
  float s=sin(a);
  float c=cos(a);
  return float2x2(c,s,-s,c);
}

float fractal3D(float3 p) {
    float z=length(p)*.1;
    float der=1.; // "running derivative", hay que aplicarle todas las operaciones de escala que se le hacen a p 
    float m=0.;
    float l2=0.;
    for (int i=0; i<7; i++) {
        //p.xz=abs(p.xz+1)-abs(p.xz-1)-p.xz;
        p=abs(p);
        p=Rotate(p,radians(_RotAngle),float3(_RotX * sin(33.0) ,_RotY,_RotZ * cos(30.0)) *_Time);
        //p.xz*=rot(-.3);
        float sc=_Scale/clamp(dot(p,p),.1,1.);
        der*=sc ;
        p=p*sc-float3(1.5,1.5,1.5);
        float l=length(p) * sin(_Time *33.0);
        if (i<10) m+=abs(l-l2 * _Time);
        l2=l * sin(_Time * _Scale);
    }
    m/=2 * sin(33.0 * _Time);
    col = float3(0,.5,1);
    col = abs(Rotate(col * cos(z * _Time), m*15, float3(1,44,0) * _Time)) + Color;
    float d = sin(length(p)/der-.05) * _Time; // se divide la distancia por el running derivative
    return d;
}



// @block DistanceFunction
inline float DistanceFunction(float3 pos)
{
    float f= fractal3D(pos*10)/ 10 ;

    return f;
}
// @endblock

// @block PostEffect
inline void PostEffect(RaymarchInfo ray, inout PostEffectOutput o)
{
    o.Albedo = col  + fixed3(_Red,_Green,_Blue);
    o.Occlusion = 0.4;
}
// @endblock

ENDCG

GrabPass {}

Pass
{
    Tags { "LightMode" = "ForwardBase" }
    Blend [_BlendSrc] [_BlendDst]
    ZWrite [_ZWrite]

    CGPROGRAM
    #include "Assets/uRaymarching/Runtime/Shaders/Include/Legacy/ForwardBaseStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile_fwdbase
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ForwardAdd" }
    ZWrite Off 
    Blend One One

    CGPROGRAM
    #include "Assets/uRaymarching/Runtime/Shaders/Include/Legacy/ForwardAddStandard.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma skip_variants INSTANCING_ON
    #pragma multi_compile_fwdadd_fullshadows
    ENDCG
}

Pass
{
    Tags { "LightMode" = "ShadowCaster" }

    CGPROGRAM
    #include "Assets/uRaymarching/Runtime/Shaders/Include/Legacy/ShadowCaster.cginc"
    #pragma target 3.0
    #pragma vertex Vert
    #pragma fragment Frag
    #pragma fragmentoption ARB_precision_hint_fastest
    #pragma multi_compile_shadowcaster
    ENDCG
}

}

Fallback "Raymarching/Fallbacks/StandardSurfaceShader"

CustomEditor "uShaderTemplate.MaterialEditor"

}