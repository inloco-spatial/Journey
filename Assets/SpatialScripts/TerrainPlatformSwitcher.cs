using UnityEngine;

public class TerrainPlatformSwitcher : MonoBehaviour
{
    public GameObject terrainForDesktopMobile;
    public GameObject terrainForVR;

    void Start()
    {
        bool isVR = false;

        // Определение платформы
        switch (Application.platform)
        {
            case RuntimePlatform.Android:
                // Дополнительная проверка для VR на Android, если необходимо
                isVR = true;
                break;
            case RuntimePlatform.IPhonePlayer:
                // iOS обычно не используется для VR в Spatial
                isVR = false;
                break;
            case RuntimePlatform.WebGLPlayer:
            case RuntimePlatform.WindowsPlayer:
            case RuntimePlatform.OSXPlayer:
                // ПК и WebGL платформы
                isVR = false;
                break;
            default:
                isVR = false;
                break;
        }

        if (terrainForDesktopMobile != null)
            terrainForDesktopMobile.SetActive(!isVR);

        if (terrainForVR != null)
            terrainForVR.SetActive(isVR);
    }
}
