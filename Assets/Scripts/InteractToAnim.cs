
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;

public class InteractToAnim : UdonSharpBehaviour
{
    public Animator animator;
    public string parName;
    public override void Interact()
    {
        animator.SetTrigger(parName);
    }
    
}
