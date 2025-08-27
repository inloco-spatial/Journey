
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class FogVRCheck : UdonSharpBehaviour
{
    public GameObject toVR;
    public GameObject nonVR;
    void Start()
    {
        if (Networking.LocalPlayer.IsUserInVR())
        {
            toVR.SetActive(true);
            nonVR.SetActive(false);
        }
        else
        {
            toVR.SetActive(false);
            nonVR.SetActive(true);
        }
    }
}
