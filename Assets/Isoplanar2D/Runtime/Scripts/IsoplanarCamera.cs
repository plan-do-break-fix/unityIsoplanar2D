using UnityEngine;

[RequireComponent(typeof(Camera))]
public class IsoplanarCamera : MonoBehaviour
{
    public float panSpeed = 10f;
    public float zoomSpeed = 5f;
    public float minSize = 3f;
    public float maxSize = 20f;

    Camera cam;

    void Awake()
    {
        cam = GetComponent<Camera>();
        cam.orthographic = true;
        transform.rotation = Quaternion.identity; // lock planar
    }

    void Update()
    {
        var dx = Input.GetAxisRaw("Horizontal");
        var dy = Input.GetAxisRaw("Vertical");
        transform.position += new Vector3(dx, dy, 0f) * panSpeed * Time.deltaTime;

        float scroll = Input.mouseScrollDelta.y;
        if (Mathf.Abs(scroll) > 0f)
        {
            cam.orthographicSize = Mathf.Clamp(
                cam.orthographicSize - scroll * zoomSpeed * Time.deltaTime,
                minSize, maxSize
            );
        }

        // hard lock against any accidental tilt/roll
        transform.rotation = Quaternion.identity;
    }
}

