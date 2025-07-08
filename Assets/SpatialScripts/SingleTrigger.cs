using UnityEngine;
using UnityEngine.Events;

/// <summary>
/// Компонент для однократного срабатывания триггера.
/// </summary>
[RequireComponent(typeof(Collider))]
public class SingleTrigger : MonoBehaviour
{
    // Событие, которое выполнится при первом срабатывании триггера.
    // Его можно настроить в инспекторе (например, вызвать метод на другом компоненте).
    public UnityEvent OnTriggered;

    // Флаг, чтобы не повторять срабатывание
    private bool _hasTriggered = false;

    private void OnTriggerEnter(Collider other)
    {
        // Если уже сработали — выходим
        if (_hasTriggered) return;

        _hasTriggered = true;

        // Выполняем всё, что нужно при первом попадании
        OnTriggered?.Invoke();

        // Отключаем этот компонент, чтобы полностью исключить дальнейшие срабатывания
        enabled = false;

        // Если нужно — можно также отключить сам Collider:
        // GetComponent<Collider>().enabled = false;
    }
}
