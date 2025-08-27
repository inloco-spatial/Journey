
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TriggerToAnimTrigger : UdonSharpBehaviour
{
    public Animator target;
    public string triggerName;
    public bool status;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player != Networking.LocalPlayer) return;
        target.SetTrigger(triggerName);
    }
}
