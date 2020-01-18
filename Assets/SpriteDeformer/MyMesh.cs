using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MyMesh : MonoBehaviour
{
    public Material mat;
    public int RegenerationCount = 3;
    public Vector3[] points;

    private MeshFilter MeshFilter;

    void Start()
    {
        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshRenderer.material = mat;

        var meshGen = new MeshGenerator();
        MeshFilter = gameObject.AddComponent<MeshFilter>();

        MeshFilter.mesh = meshGen.GenerateMeshFromPoints(points);

        for (int i = 0; i < RegenerationCount; i++)
            MeshFilter.mesh = MeshGenerator.RegenerateMesh(MeshFilter.mesh);
    }

    [ContextMenu("Save")]
    public void Save()
    {
        AssetDatabase.CreateAsset(MeshFilter.mesh, "test");
        AssetDatabase.SaveAssets();
    }
}
