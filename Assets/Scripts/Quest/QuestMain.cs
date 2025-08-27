
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class QuestMain : UdonSharpBehaviour
{
    public AnnotationSoundSystem mainScript;
    public int clipNumber;
    bool played;

    public Animator target;
    public Animator target2;
    public string triggerName;
    public bool status;

    public AudioSource source;
    public AudioClip clip;

    public bool[] trigger;
    public int triggerCount;
    public override void OnPlayerTriggerEnter(VRCPlayerApi player)
    {
        if (Networking.LocalPlayer != player) return;
        triggerCount = 0;
        for (int i = 0; i < trigger.Length; i++)
        {
            if (trigger[i] == true)            
            {
                triggerCount++;                
            }
        }
        if (trigger.Length == triggerCount)
        {            
            Debug.Log("all trigger active");
            QuestComplite();
        }
    }
    public void QuestComplite()
    {
        if (!played)
        {
            mainScript.SourcePlay(clipNumber);
            Debug.Log("Player in trigger");
            
            target.SetTrigger(triggerName);
            target2.SetTrigger(triggerName);
            source.PlayOneShot(clip);

            played = true;
        }
    }

    
}
