
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class InteractToSound : UdonSharpBehaviour
{
    public AudioSource source;
    public AudioClip clip;
    public bool soundPlayed;
    public override void Interact()
    {       
        if (soundPlayed == false)
        {
            source.PlayOneShot(clip);
            soundPlayed = true;
        }

    }
}
