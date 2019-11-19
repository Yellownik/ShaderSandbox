using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyMesh : MonoBehaviour
{
    public Material mat;
    public int RegenerationCount = 3;
    public Vector3[] points;

    void Start()
    {
        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshRenderer.material = mat;

        var meshGen = new MeshGenerator();
        var filter = gameObject.AddComponent<MeshFilter>();

        filter.mesh = meshGen.GenerateMeshFromPoints(points);

        for (int i = 0; i < RegenerationCount; i++)
        {
            filter.mesh = MeshGenerator.RegenerateMesh(filter.mesh);
        }
    }
}
