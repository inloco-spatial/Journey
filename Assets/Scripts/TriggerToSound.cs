
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class TriggerToSound : UdonSharpBehaviour
{
    public AudioSource source;
    public AudioClip clip;
    public bool soundPlayed;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (Networking.LocalPlayer != player) return;
        if (soundPlayed == false)
        {
            source.PlayOneShot(clip);
            soundPlayed = true;
        }
        
    }
}
