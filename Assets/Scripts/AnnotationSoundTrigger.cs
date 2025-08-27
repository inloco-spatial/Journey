
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class AnnotationSoundTrigger : UdonSharpBehaviour
{
    public AnnotationSoundSystem mainScript;
    public int clipNumber;
    bool played;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if(player== Networking.LocalPlayer)
        {
            if (!played)
            {
                mainScript.SourcePlay(clipNumber);
                Debug.Log("Player in trigger");
                played = true;
            }
        }
    }
}
