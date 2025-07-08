using System.Collections;
using UnityEngine;
using SpatialSys.UnitySDK;

public class AnimateThenTeleport : MonoBehaviour
{
    public Animator animator;
    public string stateName;
    public Transform targetLocation;

    public void OnInteract()
    {
        animator.Play(stateName, 0, 0f);
        float len = animator.GetCurrentAnimatorStateInfo(0).length;
        StartCoroutine(DoTeleportAfter(len));
    }

    private IEnumerator DoTeleportAfter(float delay)
    {
        yield return new WaitForSeconds(delay);

        // вот он — ваш «rig root» внутри SDK
        IAvatar avatar = SpatialBridge.actorService.localActor.avatar;
        avatar.position = targetLocation.position;
    }
}
