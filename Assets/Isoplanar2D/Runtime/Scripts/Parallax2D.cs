using UnityEngine;

public class Parallax2D : MonoBehaviour
{
    public Transform cameraTransform;
    [Range(-1f, 1f)] public float strength = 0.2f; // bg negative, fg positive

    Vector3 startPos;
    Vector3 camStart;

    void Start()
    {
        if (!cameraTransform) cameraTransform = Camera.main.transform;
        startPos = transform.position;
        camStart = cameraTransform.position;
    }

    void LateUpdate()
    {
        Vector3 camDelta = cameraTransform.position - camStart;
        transform.position = startPos + new Vector3(camDelta.x, camDelta.y, 0f) * strength;
    }
}

