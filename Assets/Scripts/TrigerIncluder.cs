
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TrigerIncluder : UdonSharpBehaviour
{
    public GameObject target;
    public GameObject targetExit;
    public bool status;
    //public bool statusExit;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player != Networking.LocalPlayer) return;
        if (target != null& targetExit != null) 
        {
            target.SetActive(status);
            targetExit.SetActive(!status);
        }
        
    }
    public override void OnPlayerTriggerExit(VRCPlayerApi player)
    {
        if (player != Networking.LocalPlayer) return;
        if (target != null & targetExit != null)
        {
            target.SetActive(!status);
            targetExit.SetActive(status);
        }
    }
}
