using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FragShader : MonoBehaviour
{

 [SerializeField] MeshRenderer _mMaterial;
    void Update()
    {
        int num = Random.Range(5, 10);
        float num2 = Random.Range(-5, 30);

        Debug.Log($"Iterations: " + num);
        Debug.Log($"Forma: " + num2);

       // _mMaterial.material.SetInt("_Iterations",num);
       // _mMaterial.material.SetFloat("_Forma",num2);

    }
}
