using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Isoplanar2D
{
    public class PosterizeRendererFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            public Shader shader;
            [Range(2,32)] public int stepsPerChannel = 6;
            public RenderPassEvent injectionPoint = RenderPassEvent.AfterRenderingPostProcessing;
        }

        class PosterizePass : ScriptableRenderPass
        {
            static readonly string kTag = "Isoplanar Posterize";
            Material mat;
            int stepsId = Shader.PropertyToID("_Steps");

            RTHandle source, destination;
            ProfilingSampler sampler = new ProfilingSampler(kTag);

            public PosterizePass(Material material, RenderPassEvent evt)
            {
                mat = material;
                renderPassEvent = evt;
            }

            public void Setup(RTHandle src, RTHandle dst) { source = src; destination = dst; }

            public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
            {
                if (mat == null) return;
                var cmd = CommandBufferPool.Get(kTag);
                using (new ProfilingScope(cmd, sampler))
                {
                    Blitter.BlitCameraTexture(cmd, source, destination, mat, 0);
                }
                context.ExecuteCommandBuffer(cmd);
                CommandBufferPool.Release(cmd);
            }
        }

        public Settings settings = new Settings();
        PosterizePass pass;
        Material material;

        public override void Create()
        {
            if (settings.shader == null)
                settings.shader = Shader.Find("Hidden/Isoplanar/Post/Posterize");
            if (settings.shader != null)
            {
                material = CoreUtils.CreateEngineMaterial(settings.shader);
                material.SetFloat("_Steps", settings.stepsPerChannel);
            }
            pass = new PosterizePass(material, settings.injectionPoint);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (material == null) return;
            var src = renderer.cameraColorTargetHandle;
            var dest = renderer.cameraColorTargetHandle; // in-place
            pass.Setup(src, dest);
            material.SetFloat("_Steps", settings.stepsPerChannel);
            renderer.EnqueuePass(pass);
        }
    }
}

