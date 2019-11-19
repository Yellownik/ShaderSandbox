using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGenerator
{
    private Vector2[] limitAreaPoints;
    private float zDisplacement = 0f;

    public Vector3[] CornerPoints
    {
        get; private set;
    }

    private Mesh GenerateMesh()
    {
        Triangulator triangulator = new Triangulator(limitAreaPoints);
        int[] indices = triangulator.Triangulate();

        Vector3[] vertices = new Vector3[limitAreaPoints.Length];
        Vector2[] uv = new Vector2[limitAreaPoints.Length];

        float minX = 0;
        float minY = 0;
        float maxX = 0;
        float maxY = 0;

        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] = new Vector3(limitAreaPoints[i].x, limitAreaPoints[i].y, zDisplacement);
            if (vertices[i].x < minX)
                minX = vertices[i].x;

            if (vertices[i].y < minY)
                minY = vertices[i].y;

            if (vertices[i].x > maxX)
                maxX = vertices[i].x;

            if (vertices[i].y > maxY)
                maxY = vertices[i].y;
        }

        for (int i = 0; i < uv.Length; i++)
        {
            uv[i] = new Vector2((vertices[i].x - minX) / (maxX - minX), (vertices[i].y - minY) / (maxY - minY));
        }

        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = indices;
        mesh.uv = uv;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        return mesh;
    }

    public static Mesh RegenerateMesh(Mesh mesh)
    {
        Vector3[] oldVertices = mesh.vertices;
        int[] oldIndices = mesh.GetIndices(0);
        Vector2[] oldUVs = mesh.uv;

        List<Vector3> vertices = new List<Vector3>();
        List<int> triangles = new List<int>();
        List<Vector2> uvs = new List<Vector2>();

        int newI = 0;
        for (int i = 0; i < oldIndices.Length; i += 3)
        {
            Vector3 a = oldVertices[oldIndices[i]];
            Vector3 b = oldVertices[oldIndices[i + 1]];
            Vector3 c = oldVertices[oldIndices[i + 2]];

            Vector3 ab = (a + b) * 0.5f;
            Vector3 bc = (b + c) * 0.5f;
            Vector3 ca = (c + a) * 0.5f;
            // 0  1  2  3   4   5
            vertices.AddRange(new Vector3[] { a, b, c, ab, bc, ca });

            // a, ab, ca
            triangles.AddRange(new int[] { newI + 0, newI + 3, newI + 5 });
            // ab, b, bc                 
            triangles.AddRange(new int[] { newI + 3, newI + 1, newI + 4 });
            // bc, c, ca                 
            triangles.AddRange(new int[] { newI + 4, newI + 2, newI + 5 });
            // ca, ab, bc
            triangles.AddRange(new int[] { newI + 5, newI + 3, newI + 4 });
            newI += 6;

            Vector2 aUV = oldUVs[oldIndices[i]];
            Vector2 bUV = oldUVs[oldIndices[i + 1]];
            Vector2 cUV = oldUVs[oldIndices[i + 2]];
            uvs.AddRange(new Vector2[] { aUV, bUV, cUV, (aUV + bUV) / 2f, (bUV + cUV) / 2f, (cUV + aUV) / 2f });
        }

        Mesh resultMesh = new Mesh();
        resultMesh.vertices = vertices.ToArray();
        resultMesh.triangles = triangles.ToArray();
        resultMesh.uv = uvs.ToArray();

        return resultMesh;
    }

    private Mesh DeleteVertices(Mesh mesh)
    {
        List<Vector3> oldVertices = new List<Vector3>();
        mesh.GetVertices(oldVertices);
        int[] oldIndices = mesh.GetIndices(0);

        List<int> indices = new List<int>();

        Dictionary<Vector3, List<int>> dict = new Dictionary<Vector3, List<int>>();
        for (int i = 0; i < oldVertices.Count; i++)
        {
            if (dict.ContainsKey(oldVertices[i]) == false)
            {
                dict.Add(oldVertices[i], new List<int>() { i });
            }
            else
            {
                dict[oldVertices[i]].Add(i);
            }
        }

        List<Vector3> vertices = new List<Vector3>();
        vertices.AddRange(dict.Keys);

        for (int i = 0; i < oldIndices.Length; i++)
        {
            Vector3 vec = oldVertices[oldIndices[i]];
            indices.Add(vertices.IndexOf(vec));
        }

        Mesh resultMesh = new Mesh();
        resultMesh.vertices = vertices.ToArray();
        resultMesh.triangles = indices.ToArray();
        return resultMesh;
    }

    public Mesh GenerateMeshFromPoints(Vector3[] points)
    {
        limitAreaPoints = new Vector2[points.Length];
        float zAverageValue = 0;

        for (int i = 0; i < limitAreaPoints.Length; i++)
        {
            zAverageValue += points[i].z;
            this.limitAreaPoints[i] = new Vector2(points[i].x, points[i].y);
        }

        zAverageValue /= points.Length;
        zDisplacement = zAverageValue;

        return GenerateMesh();
    }
}