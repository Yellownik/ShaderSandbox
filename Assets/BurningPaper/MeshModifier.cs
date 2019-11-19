using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshModifier : MonoBehaviour
{
    void Start()
    {
        float maxVal = 0.0f;
        Material dissolveMaterial = GetComponent<Renderer>().material;
        var verts = GetComponent<MeshFilter>().mesh.vertices;
        for (int i = 0; i < verts.Length; i++)
        {
            var v1 = verts[i];
            for (int j = 0; j < verts.Length; j++)
            {
                if (j == i) continue;
                var v2 = verts[j];
                float mag = (v1 - v2).magnitude;
                if (mag > maxVal) maxVal = mag;
            }
        }
        dissolveMaterial.SetFloat("_LargestVal", maxVal * 0.5f);
    }
}
