using System.Collections;
using UnityEngine;
using SpatialSys.UnitySDK; // SpatialAvatar находится здесь

public class AvatarLayerAssigner : MonoBehaviour
{
    [Tooltip("Имя слоя, который создан под аватар")]
    public string avatarLayerName = "AvatarLayer";

    void Start()
    {
        // Ждём один кадр — пока Spatial не заспавнит Local Avatar
        StartCoroutine(AssignLocalAvatarLayer());
    }

    IEnumerator AssignLocalAvatarLayer()
    {
        yield return null;

        // Находим компонент SpatialAvatar на сцене (локальный спавнится единожды)
        var localAvatar = FindObjectOfType<SpatialAvatar>();
        if (localAvatar != null)
        {
            int layer = LayerMask.NameToLayer(avatarLayerName);
            SetLayerRecursively(localAvatar.gameObject, layer);
            Debug.Log($"[AvatarLayerAssigner] Assigned layer '{avatarLayerName}' to LocalAvatar");
        }
        else
        {
            Debug.LogWarning("[AvatarLayerAssigner] SpatialAvatar not found!");
        }
    }

    void SetLayerRecursively(GameObject go, int layer)
    {
        go.layer = layer;
        foreach (Transform child in go.transform)
            SetLayerRecursively(child.gameObject, layer);
    }
}
