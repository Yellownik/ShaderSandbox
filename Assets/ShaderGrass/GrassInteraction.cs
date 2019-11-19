using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassInteraction : MonoBehaviour
{
    public float radius = 2;

    Renderer rend;

    void Start()
    {
        rend = GetComponent<Renderer>();
    }

    void Update()
    {
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, Mathf.Infinity))
        {
            var hitlocal = transform.InverseTransformPoint(hit.point);
            hitlocal = hit.point;

            rend.material.SetVector("_ObjPos", new Vector4(hitlocal.x, 0, hitlocal.z, 0));
        }
    }
}
