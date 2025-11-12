using UnityEditor;
using UnityEngine;
using System.IO;

public class GenerateMatcapTexture : Editor
{
    [MenuItem("Isoplanar2D/Generate Simple Matcap (256x256)")]
    static void Generate()
    {
        int size = 256;
        var tex = new Texture2D(size, size, TextureFormat.RGBA32, false);
        for (int y = 0; y < size; y++)
        for (int x = 0; x < size; x++)
        {
            float2 uv = new float2((x + 0.5f) / size * 2f - 1f, (y + 0.5f) / size * 2f - 1f);
            float r = Mathf.Clamp01(1f - uv.magnitude);
            // radial highlight with soft center
            Color c = Color.Lerp(new Color(0.6f,0.6f,0.6f,1), new Color(1f,1f,1f,1), Mathf.Pow(r, 2f));
            tex.SetPixel(x, y, c);
        }
        tex.Apply(false, false);

        string path = "Assets/Isoplanar2D/Generated_Matcap.png";
        var png = tex.EncodeToPNG();
        File.WriteAllBytes(path, png);
        AssetDatabase.Refresh();

        var importer = (TextureImporter)AssetImporter.GetAtPath(path);
        importer.wrapMode = TextureWrapMode.Clamp;
        importer.filterMode = FilterMode.Bilinear;
        importer.mipmapEnabled = true;
        importer.SaveAndReimport();

        Debug.Log($"Generated matcap at {path}");
    }

    struct float2
    {
        public float x, y;
        public float magnitude => Mathf.Sqrt(x * x + y * y);
        public float2(float a, float b) { x = a; y = b; }
        public static float2 operator *(float2 v, float s) => new float2(v.x * s, v.y * s);
        public static float2 operator -(float2 a, float2 b) => new float2(a.x - b.x, a.y - b.y);
    }
}

