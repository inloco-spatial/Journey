#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

public class AssignTerrainData : EditorWindow
{
    Terrain terrain;
    TerrainData terrainData;

    [MenuItem("Tools/Assign TerrainData")]
    public static void ShowWindow()
    {
        GetWindow<AssignTerrainData>("Assign TerrainData");
    }

    void OnGUI()
    {
        terrain = (Terrain)EditorGUILayout.ObjectField("Terrain", terrain, typeof(Terrain), true);
        terrainData = (TerrainData)EditorGUILayout.ObjectField("New TerrainData", terrainData, typeof(TerrainData), false);

        GUI.enabled = terrain != null && terrainData != null;

        if (GUILayout.Button("Assign"))
        {
            Undo.RecordObject(terrain, "Assign TerrainData");
            terrain.terrainData = terrainData;
            EditorUtility.SetDirty(terrain);
            Debug.Log($"✅ TerrainData reassigned to: {terrainData.name}");
        }

        GUI.enabled = true;
    }
}
#endif
