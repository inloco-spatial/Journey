using UnityEngine;

public class HUD_FollowSpatialCamera : MonoBehaviour
{
    public float distanceFromCamera = 1.0f;
    Transform cam;

    void Start()
    {
        Camera[] all = Object.FindObjectsOfType<Camera>();
        foreach (var c in all)
        {
            if (c.enabled && c.transform.parent == null)
            {
                cam = c.transform;
                break;
            }
        }
        if (cam == null)
            Debug.LogWarning("Камера Spatial не найдена!");
    }

    void LateUpdate()
    {
        if (cam == null) return;

        transform.position = cam.position + cam.forward * distanceFromCamera;
        transform.LookAt(cam.position);
        transform.Rotate(0, 180, 0); // Повернуть Quad в правильную сторону
    }
}
