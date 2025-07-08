using UnityEngine;

public class TriggerCounter : MonoBehaviour
{
    [Header("ќбъекты, которые покажем после 5 срабатываний")]
    public GameObject objectToShow1;
    public GameObject objectToShow2;

    // флаги, какие из 5 триггеров уже сработали
    private bool[] _done = new bool[5];
    private int _count;

    // 5 публичных методов дл€ Inspector-а
    public void Trigger0() { Register(0); }
    public void Trigger1() { Register(1); }
    public void Trigger2() { Register(2); }
    public void Trigger3() { Register(3); }
    public void Trigger4() { Register(4); }

    private void Register(int idx)
    {
        if (_done[idx]) return;        // уже считали Ц выходим
        _done[idx] = true;             // помечаем
        _count++;                      // увеличиваем общий счЄтчик
        Debug.Log($"TriggerCounter: пройден триггер #{idx} ({_count}/5)");
        if (_count == 5) ShowObjects();
    }

    private void ShowObjects()
    {
        Debug.Log("TriggerCounter: все 5 пройдены, показываю объекты");
        objectToShow1?.SetActive(true);
        objectToShow2?.SetActive(true);
        // можно отключить этот скрипт, если больше не нужно:
        enabled = false;
    }
}
