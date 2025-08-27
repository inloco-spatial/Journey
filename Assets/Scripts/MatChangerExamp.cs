
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class MatChangerExamp : UdonSharpBehaviour
{
    public GameObject matVat1;
    public GameObject matVat2;
    public bool firstMat;    

    public override void Interact()
    {
        if (firstMat)
        {
            matVat1.SetActive(true);
            matVat2.SetActive(false);
            firstMat = false;
        }
        else
        {
            matVat1.SetActive(false);
            matVat2.SetActive(true);
            firstMat = true;
        } 
    }
}
