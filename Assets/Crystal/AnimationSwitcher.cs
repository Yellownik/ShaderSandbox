using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationSwitcher : MonoBehaviour
{
	public float minSlowAnimTime;
	public float maxSlowAnimTime;

	public float minFastAnimTime;
	public float maxFastAnimTime;

	private Animator animator;

	void Start()
	{
		animator = GetComponent<Animator> ();

		StartCoroutine(RandomAnimationSwitch());
	}
	
	private IEnumerator RandomAnimationSwitch()
	{
		while (true) 
		{
			animator.SetBool ("IsFastAnim", false);
			yield return new WaitForSeconds (Random.Range (minSlowAnimTime, maxSlowAnimTime));

			animator.SetBool ("IsFastAnim", true);
			yield return new WaitForSeconds (Random.Range (minFastAnimTime, maxFastAnimTime));
		}
	}

}
