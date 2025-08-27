
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using UnityEngine.UI;

public class ToggleHideScreen : UdonSharpBehaviour
{
    public Toggle toggle;
    public GameObject target;
    public void Start()
    {
        if (toggle.isOn)
        {
            target.SetActive(true);
        }
        else
        {
            target.SetActive(false);
        }
    }
    public void ToggleUpdate()
    {
        if (toggle.isOn)
        {
            target.SetActive(true);
        }
        else
        {
            target.SetActive(false);
        }
    }
}
