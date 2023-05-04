using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class Cell : MonoBehaviour
{
    [SerializeField] Image _mMaterial;
    void Update()
    {
        int num = Random.Range(0, 2);
        int num2 = Random.Range(0, 11);
        int num3 = Random.Range(1, 26);

        if(num2 % 2 == 0) num2 = 1;
        else num2 = 0;

        _mMaterial.material.SetFloat("_Size",(float)num);
        _mMaterial.material.SetFloat("_IsMovement",(float) num2);
        _mMaterial.material.SetFloat("_BlendMode", num3);


    }
}
