using UnityEngine;

public class SpatialAudioTrigger : MonoBehaviour
{
    public enum SourceType { PlaySFX, SwitchBGM, PlayVoice, MuteZone }

    [Header("Тип триггера")]
    public SourceType type = SourceType.PlaySFX;

    [Header("Клип для воспроизведения (для PlayVoice используется clip или слот)")]
    public AudioClip clip;

    [Header("Приглушать фон")]
    public bool duckBGM = true;

    [Header("Voice Slots (макс 5)")]
    [Tooltip("Заполните до 5 клипов и вызывайте PlayVoiceSlot(index) из Animation Event")]
    public AudioClip[] voiceSlots = new AudioClip[5];

    /// <summary>Spatial Trigger OnEnter</summary>
    public void OnUserEnter()
    {
        if (type == SourceType.MuteZone)
            AudioManager.Instance.MuteAll(true);
        else
            Execute();
    }

    /// <summary>Spatial Trigger OnExit</summary>
    public void OnUserExit()
    {
        if (type == SourceType.MuteZone)
            AudioManager.Instance.MuteAll(false);
    }

    /// <summary>Animation Event: проиграть clip</summary>
    public void PlayAssignedClip()
    {
        if (type != SourceType.MuteZone)
            Execute();
    }

    /// <summary>Animation Event: проиграть клип из voiceSlots по индексу</summary>
    public void PlayVoiceSlot(int slotIndex)
    {
        if (type != SourceType.PlayVoice) return;
        if (slotIndex < 0 || slotIndex >= voiceSlots.Length) return;

        var slotClip = voiceSlots[slotIndex];
        if (slotClip == null) return;

        AudioManager.Instance.PlayVoice(slotClip, duck: false);
    }

    private void Execute()
    {
        if (AudioManager.Instance == null) return;

        switch (type)
        {
            case SourceType.PlaySFX:
                AudioManager.Instance.PlaySFX(clip, duckBGM);
                break;
            case SourceType.SwitchBGM:
                AudioManager.Instance.SwitchBGM(clip);
                break;
            case SourceType.PlayVoice:
                AudioManager.Instance.PlayVoice(clip, duckBGM);
                break;
        }
    }
}
