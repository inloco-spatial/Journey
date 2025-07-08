using UnityEngine;
using System.Collections;

[DisallowMultipleComponent]
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [Header("Основные AudioSource")]
    public AudioSource bgmSource;    // фон
    public AudioSource sfxSource;    // эффекты
    public AudioSource voiceSource;  // озвучка/интервью

    [Header("Параметры приглушения (ducking)")]
    [Range(0f, 1f)] public float duckLevel = 0.3f;
    public float duckFadeDuration = 0.2f;

    [Header("Параметры смены музыки")]
    public float bgmFadeDuration = 1f;

    private float defaultBgmVolume;
    private float switchFactor = 1f;
    private float duckFactor = 1f;
    private int duckCount = 0;

    private bool isMuted = false;
    private float savedBgmVolume;
    private float savedSfxVolume;
    private float savedVoiceVolume;

    private Coroutine switchCoroutine;
    private Coroutine duckCoroutine;

    private void Awake()
    {
        if (Instance == null) Instance = this;
        else { Destroy(gameObject); return; }

        // Автоматический поиск источников, можно назначить вручную
        var srcs = GetComponentsInChildren<AudioSource>();
        foreach (var src in srcs)
        {
            if (src.loop)
                bgmSource = bgmSource ?? src;
            else if (src.spatialBlend > 0.5f)
                sfxSource = sfxSource ?? src;
            else
                voiceSource = voiceSource ?? src;
        }

        defaultBgmVolume = bgmSource ? bgmSource.volume : 1f;
    }

    /// <summary>Плавная смена фоновой музыки</summary>
    public void SwitchBGM(AudioClip newClip)
    {
        if (bgmSource == null || newClip == null) return;
        if (switchCoroutine != null) StopCoroutine(switchCoroutine);
        switchCoroutine = StartCoroutine(SwitchBgmRoutine(newClip));
    }

    private IEnumerator SwitchBgmRoutine(AudioClip newClip)
    {
        float t = 0f;
        // Fade out
        while (t < bgmFadeDuration)
        {
            t += Time.deltaTime;
            switchFactor = 1f - Mathf.Clamp01(t / bgmFadeDuration);
            UpdateBgmVolume();
            yield return null;
        }
        // Switch clip
        bgmSource.clip = newClip;
        bgmSource.Play();
        t = 0f;
        // Fade in
        while (t < bgmFadeDuration)
        {
            t += Time.deltaTime;
            switchFactor = Mathf.Clamp01(t / bgmFadeDuration);
            UpdateBgmVolume();
            yield return null;
        }
        switchFactor = 1f;
        UpdateBgmVolume();
        switchCoroutine = null;
    }

    /// <summary>Проиграть SFX с опциональным duck</summary>
    public void PlaySFX(AudioClip clip, bool duck = true)
    {
        if (sfxSource == null || clip == null) return;
        sfxSource.PlayOneShot(clip);
        if (duck) StartDuck();
        if (duck) StartCoroutine(EndDuckAfter(clip.length));
    }

    /// <summary>Проиграть Voice с опциональным duck</summary>
    public void PlayVoice(AudioClip clip, bool duck = true)
    {
        if (voiceSource == null || clip == null) return;
        voiceSource.clip = clip;
        voiceSource.Play();
        if (duck) StartDuck();
        if (duck) StartCoroutine(EndDuckAfter(clip.length));
    }

    private void StartDuck()
    {
        if (duckCount++ == 0)
        {
            if (duckCoroutine != null) StopCoroutine(duckCoroutine);
            duckCoroutine = StartCoroutine(DuckRoutine());
        }
    }

    private IEnumerator EndDuckAfter(float delay)
    {
        yield return new WaitForSeconds(delay);
        if (--duckCount == 0)
        {
            if (duckCoroutine != null) StopCoroutine(duckCoroutine);
            duckCoroutine = StartCoroutine(UnduckRoutine());
        }
    }

    private IEnumerator DuckRoutine()
    {
        float start = duckFactor;
        float t = 0f;
        while (t < duckFadeDuration)
        {
            t += Time.deltaTime;
            duckFactor = Mathf.Lerp(start, duckLevel, t / duckFadeDuration);
            UpdateBgmVolume();
            yield return null;
        }
        duckFactor = duckLevel;
        UpdateBgmVolume();
    }

    private IEnumerator UnduckRoutine()
    {
        float start = duckFactor;
        float t = 0f;
        while (t < duckFadeDuration)
        {
            t += Time.deltaTime;
            duckFactor = Mathf.Lerp(start, 1f, t / duckFadeDuration);
            UpdateBgmVolume();
            yield return null;
        }
        duckFactor = 1f;
        UpdateBgmVolume();
    }

    private void UpdateBgmVolume()
    {
        bgmSource.volume = defaultBgmVolume * switchFactor * duckFactor;
    }

    /// <summary>Мьютит или размьючивает всё аудио</summary>
    public void MuteAll(bool mute)
    {
        if (isMuted == mute) return;
        isMuted = mute;
        if (mute)
        {
            savedBgmVolume   = bgmSource.volume;
            savedSfxVolume   = sfxSource.volume;
            savedVoiceVolume = voiceSource.volume;
            bgmSource.volume   = 0f;
            sfxSource.volume   = 0f;
            voiceSource.volume = 0f;
        }
        else
        {
            bgmSource.volume   = savedBgmVolume;
            sfxSource.volume   = savedSfxVolume;
            voiceSource.volume = savedVoiceVolume;
        }
    }
}
