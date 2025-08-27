
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class SpatialLikeUI : UdonSharpBehaviour
{
    public Animator anim;
    public string openAnimName;
    //public string closeAnimName;

    public void Start()
    {
        VRCPlayerApi player = Networking.LocalPlayer;
        OnPlayerTriggerExit(player);
    }
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player != Networking.LocalPlayer) return;
        anim.SetBool(openAnimName, true);
    }
    public override void OnPlayerTriggerExit(VRCPlayerApi player)
    {
        if (player != Networking.LocalPlayer) return;
        anim.SetBool(openAnimName, false);
    }
}
