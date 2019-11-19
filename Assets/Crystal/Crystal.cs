using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

#if !UNITY
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(Crystal))]
public class CrystalEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Crystal myScript = (Crystal)target;
        if (EditorApplication.isPlaying &&  GUILayout.Button("Show"))
        {
            foreach (var targ in targets)
            {
                (targ as Crystal).Show();
            }
        }
    }
}
#endif

public class Crystal: MonoBehaviour
{
    [SerializeField] private float appearDuration = 1;
    [SerializeField] private SpriteRenderer spriteRenderer;

    void Start()
    {
        //gameObject.SetActive(false);
    }

    [ContextMenu("Show")]
    public void Show()
    {
        gameObject.SetActive(true);
        StartCoroutine(DissolveCoro());
    }

    private IEnumerator DissolveCoro(System.Action callback = null)
    {
        spriteRenderer.material.SetFloat("_DissolveValue", 0);
        float rate = 1f / appearDuration;
        float t = 0;

        while (t < 1)
        {
            yield return null;
            t += Time.deltaTime * rate;
            spriteRenderer.material.SetFloat("_DissolveValue", t);
        }

        spriteRenderer.material.SetFloat("_DissolveValue", 1);

        if (callback != null)
            callback();
    }
}

