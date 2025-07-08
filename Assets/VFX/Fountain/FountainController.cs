using SpatialSys.UnitySDK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FountainController : SpatialNetworkBehaviour, IVariablesChanged
{
	[SerializeField] Slider slider;
	[SerializeField] Animator animator;
	NetworkVariable<float> _gravity = new(id: 0, initialValue: 1.0f);
	
	public override void Spawned()
	{
	}
	public void OnVariablesChanged(NetworkObjectVariablesChangedEventArgs args)
	{
		if(args.changedVariables.ContainsKey(_gravity.id))
		{
			animator.SetFloat("gravity", _gravity.value);
			slider.SetValueWithoutNotify(_gravity.value);
		}
	}
	public void ChangeGravity()
	{
		_gravity.value = slider.value;
	}
	public void ZeroGravity()
	{
		_gravity.value = 0.5f;
	}
}