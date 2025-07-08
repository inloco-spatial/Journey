using UnityEngine;

/// <summary>
/// Простая реализация контролируемого рандомного качания лодки на волнах.
/// Attach this script to your boat GameObject and tweak the parameters for realistic wave motion.
/// Works with Unity/Spatial.io (Assembly configured externally).
/// </summary>
public class BoatWaveMotion : MonoBehaviour
{
    [Header("Wave Settings")]
    [Tooltip("Amplitude of vertical bobbing (meters)")]
    public float waveAmplitude = 0.5f;
    [Tooltip("Speed multiplier for wave motion")]
    public float waveSpeed = 1.0f;
    [Tooltip("Frequency of Perlin noise sample")] 
    public float waveFrequency = 0.5f;

    [Header("Rotation Settings")]
    [Tooltip("Maximum roll angle (degrees)")]
    public float maxRollAngle = 10f;
    [Tooltip("Maximum pitch angle (degrees)")]
    public float maxPitchAngle = 5f;

    // Начальные параметры позиции и ориентации
    private Vector3 initialPosition;
    private Quaternion initialRotation;

    // Случайные оффсеты для Perlin Noise
    private float noiseOffsetY;
    private float noiseOffsetRot;

    private void Start()
    {
        // Сохраняем стартовые позицию и поворот
        initialPosition = transform.localPosition;
        initialRotation = transform.localRotation;

        // Инициализируем случайные оффсеты
        noiseOffsetY = Random.Range(0f, 100f);
        noiseOffsetRot = Random.Range(0f, 100f);
    }

    private void Update()
    {
        // Время с учетом скорости волн
        float t = Time.time * waveSpeed;

        // Вертикальное колебание по Perlin Noise
        float noiseY = Mathf.PerlinNoise(t * waveFrequency, noiseOffsetY);
        float y = (noiseY * 2f - 1f) * waveAmplitude;
        transform.localPosition = initialPosition + Vector3.up * y;

        // Качка: ролл и питч по разным шумовым значениям
        float noiseRoll = Mathf.PerlinNoise(t * waveFrequency, noiseOffsetY + 50f);
        float noisePitch = Mathf.PerlinNoise(t * waveFrequency, noiseOffsetRot + 50f);
        float roll = (noiseRoll * 2f - 1f) * maxRollAngle;
        float pitch = (noisePitch * 2f - 1f) * maxPitchAngle;
        transform.localRotation = initialRotation * Quaternion.Euler(pitch, 0f, roll);
    }
}
