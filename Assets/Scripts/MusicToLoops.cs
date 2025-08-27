
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class MusicToLoops : UdonSharpBehaviour
{
    public AudioSource source;
    public AudioClip clip;

    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (player == Networking.LocalPlayer)
        {
            source.clip = clip;
            source.Play();
        }
    }
}
