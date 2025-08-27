
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class EventByAnim : UdonSharpBehaviour
{
    public GameObject target;
    public void AnimEvent()
    {
        Networking.LocalPlayer.TeleportTo(target.transform.position,target.transform.rotation);
        Debug.Log("Anim Evented");
    }
}
