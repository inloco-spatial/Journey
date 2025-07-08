using System.Collections;
using UnityEngine;

[RequireComponent(typeof(SkinnedMeshRenderer))]
public class BlinkController : MonoBehaviour
{
    [Header("BlendShape Settings")]
    [SerializeField] private int blinkBlendShapeIndex = 0;

    [Header("Blink Timing")]
    [SerializeField] private float minBlinkInterval = 3f;
    [SerializeField] private float maxBlinkInterval = 7f;
    [SerializeField] private float closeDuration = 0.05f;
    [SerializeField] private float holdClosedDuration = 0.05f;
    [SerializeField] private float openDuration = 0.1f;

    [Header("Double Blink")]
    [SerializeField] private float doubleBlinkChance = 0.2f;
    [SerializeField] private float doubleBlinkDelay = 0.2f;

    [Header("Eye Movement (Y with Optional Z Offset)")]
    [SerializeField] private Transform eyeTransform;
    [Tooltip("Min local Y-axis rotation angle (degrees)")]
    [SerializeField] private float minYAngle = -10f;
    [Tooltip("Max local Y-axis rotation angle (degrees)")]
    [SerializeField] private float maxYAngle = 10f;
    [Tooltip("Enable secondary Z-axis offset")]
    [SerializeField] private bool useZOffset = false;
    [Tooltip("Min local Z-axis rotation angle (degrees)")]
    [SerializeField] private float minZAngle = -5f;
    [Tooltip("Max local Z-axis rotation angle (degrees)")]
    [SerializeField] private float maxZAngle = 5f;
    [Tooltip("Degrees per second when moving gaze")]
    [SerializeField] private float eyeMoveSpeed = 30f;

    private SkinnedMeshRenderer skinnedMesh;
    private int blendShapeCount;
    private float currentYAngle;
    private float currentZAngle;

    private void Awake()
    {
        skinnedMesh = GetComponent<SkinnedMeshRenderer>();
        if (skinnedMesh == null)
        {
            Debug.LogError("BlinkController requires a SkinnedMeshRenderer component.");
            enabled = false;
            return;
        }

        blendShapeCount = skinnedMesh.sharedMesh.blendShapeCount;
        if (blinkBlendShapeIndex < 0 || blinkBlendShapeIndex >= blendShapeCount)
        {
            Debug.LogError($"Invalid blendshape index {blinkBlendShapeIndex}. Mesh has {blendShapeCount} blendshape(s). Please set a valid index.");
            enabled = false;
            return;
        }

        if (eyeTransform == null)
            Debug.LogWarning("Eye Transform not set. Eye movement will be disabled.");
        else
        {
            Vector3 angles = eyeTransform.localEulerAngles;
            currentYAngle = angles.y;
            currentZAngle = angles.z;
        }
    }

    private void Start()
    {
        if (enabled)
            StartCoroutine(BlinkAndGazeRoutine());
    }

    private IEnumerator BlinkAndGazeRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(Random.Range(minBlinkInterval, maxBlinkInterval));

            yield return BlinkOnce();

            if (Random.value < doubleBlinkChance)
            {
                yield return new WaitForSeconds(doubleBlinkDelay);
                yield return BlinkOnce();
            }

            if (eyeTransform != null)
                yield return MoveGaze();
        }
    }

    private IEnumerator BlinkOnce()
    {
        yield return LerpBlendShape(0f, 100f, closeDuration);
        yield return new WaitForSeconds(holdClosedDuration);
        yield return LerpBlendShape(100f, 0f, openDuration);
    }

    private IEnumerator MoveGaze()
    {
        // Determine target angles
        float targetY = Random.Range(minYAngle, maxYAngle);
        int safety = 0;
        while (Mathf.Approximately(targetY, currentYAngle) && safety++ < 5)
            targetY = Random.Range(minYAngle, maxYAngle);

        float targetZ = currentZAngle;
        if (useZOffset)
        {
            targetZ = Random.Range(minZAngle, maxZAngle);
            safety = 0;
            while (Mathf.Approximately(targetZ, currentZAngle) && safety++ < 5)
                targetZ = Random.Range(minZAngle, maxZAngle);
        }

        // Calculate deltas
        float deltaY = Mathf.DeltaAngle(currentYAngle, targetY);
        float deltaZ = Mathf.DeltaAngle(currentZAngle, targetZ);
        float maxDelta = Mathf.Max(Mathf.Abs(deltaY), Mathf.Abs(deltaZ));
        float duration = Mathf.Abs(maxDelta) / eyeMoveSpeed;

        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            float y = Mathf.LerpAngle(currentYAngle, targetY, t);
            float z = Mathf.LerpAngle(currentZAngle, targetZ, t);
            eyeTransform.localRotation = Quaternion.Euler(0f, y, z);
            yield return null;
        }

        eyeTransform.localRotation = Quaternion.Euler(0f, targetY, targetZ);
        currentYAngle = targetY;
        currentZAngle = targetZ;
    }

    private IEnumerator LerpBlendShape(float from, float to, float duration)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float weight = Mathf.Lerp(from, to, elapsed / duration);
            skinnedMesh.SetBlendShapeWeight(blinkBlendShapeIndex, weight);
            yield return null;
        }
        skinnedMesh.SetBlendShapeWeight(blinkBlendShapeIndex, to);
    }
}
