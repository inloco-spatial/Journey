
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class QuestEvents : UdonSharpBehaviour
{
    public int questNumber;
    public QuestMain mainScript;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (Networking.LocalPlayer != player) return;
        mainScript.trigger[questNumber] = true;
    }
}
