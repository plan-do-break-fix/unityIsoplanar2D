using UnityEditor;
using UnityEngine;
using System.IO;

public class GenerateToonRampTexture : Editor
{
    [MenuItem("Isoplanar2D/Generate Toon Ramp (256x1)")]
    static void Generate()
    {
        int width = 256;
        var tex = new Texture2D(width, 1, TextureFormat.RGBA32, false);
        // 3-band example: dark/mid/light hard steps
        for (int x = 0; x < width; x++)
        {
            float u = x / (float)(width - 1);
            Color c = u < 0.33f ? new Color(0.25f,0.25f,0.25f,1)
                     : u < 0.66f ? new Color(0.55f,0.55f,0.55f,1)
                                 : new Color(0.90f,0.90f,0.90f,1);
            tex.SetPixel(x, 0, c);
        }
        tex.Apply(false, false);

        string path = "Assets/Isoplanar2D/Generated_ToonRamp.png";
        var png = tex.EncodeToPNG();
        File.WriteAllBytes(path, png);
        AssetDatabase.Refresh();

        var importer = (TextureImporter)AssetImporter.GetAtPath(path);
        importer.wrapMode = TextureWrapMode.Clamp;
        importer.filterMode = FilterMode.Point;
        importer.mipmapEnabled = false;
        importer.SaveAndReimport();

        Debug.Log($"Generated toon ramp at {path}");
    }
}

