using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OnOffPanel : MonoBehaviour
{
    [SerializeField] GameObject _panels;

    public void OnOffPanels()
    {
        if (_panels.activeInHierarchy)
        {
            _panels.SetActive(false);
            return;
        }
            _panels.SetActive(true);
    }
}
