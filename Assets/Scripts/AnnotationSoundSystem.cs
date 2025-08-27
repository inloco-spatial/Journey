
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class AnnotationSoundSystem : UdonSharpBehaviour
{
    public AudioSource source;
    public AudioClip[] clips;
    

    public void SourcePlay(int clipNumber)
    {
        source.Stop();
        source.PlayOneShot(clips[clipNumber]);
        
    }
}
