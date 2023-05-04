using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ControlShader : MonoBehaviour
{

    [SerializeField] Image _mMaterial;
    [SerializeField] Slider [] _sliderRGB;
    [SerializeField] Slider[] _PosIlumination;

    [SerializeField] Slider[] _posAngle;
    [SerializeField] Slider[] _sliderColor;

    [SerializeField] Slider _interPolation;

    private void Start()
    {
        _PosIlumination[1].minValue = -2.0f;
    }
    void Update()
    {
        _mMaterial.material.SetFloat("_Red", _sliderRGB[0].value * 4.0f);
        _mMaterial.material.SetFloat("_Green", _sliderRGB[1].value * 4.0f);
        _mMaterial.material.SetFloat("_Blue", _sliderRGB[2].value * 4.0f);

        _mMaterial.material.SetFloat("_PosXIlumination",_PosIlumination[0].value * 2.0f);
        _mMaterial.material.SetFloat("_PosYIlumination", _PosIlumination[1].value * 7.47f);

        _mMaterial.material.SetFloat("_PosX", _posAngle[0].value);
        _mMaterial.material.SetFloat("_PosY", _posAngle[1].value);
        _mMaterial.material.SetColor("_ColorA", new Color(_sliderColor[0].value , _sliderColor[1].value , _sliderColor[2].value ));

        _mMaterial.material.SetFloat("_AmountIterpolation", _interPolation.value * 4f);



    }
}
