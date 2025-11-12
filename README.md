# Isoplanar2D – 3D assets, strictly planar camera, iconic 2D look (Unity URP)

This package sets up a “2D-but-richer” pipeline: you author in 3D, render orthographically, and enforce a crisp, iconic style via toon ramps, optional matcaps, inverted-hull outlines, and a lightweight posterize pass. Camera moves are *strictly isoplanar* (pan/zoom only; no tilt/roll/orbit).

---

## 0) Prerequisites

- Unity 6.x (URP)
- URP Forward Renderer asset assigned in **Project Settings → Graphics**
- A URP Renderer Data (e.g., *ForwardRenderer*) referenced by the URP Asset

**Project switches (recommended):**
- Disable TAA; use MSAA (2x–4x) for edges
- Disable SSAO and screen-space shadows for a cleaner graphic read
- Keep shadows hard or short-radius soft; low distance

---

## 1) Camera Setup (Strictly Isoplanar)

1. Create an empty scene.
2. Select the Main Camera:
   - Projection: **Orthographic**
   - Rotation: **(0,0,0)**
   - Add **`IsoplanarCamera`** component.
3. (Optional) Use Cinemachine:
   - Add a **Cinemachine Virtual Camera** set to **Orthographic**.
   - Use *Framing Transposer* for follow, *Confiner 2D* for bounds.
   - Lock camera rotation to identity (0,0,0).

**Axis:**
- `WASD` pans (via Input axes).
- Mouse wheel zooms (clamped between `minSize` and `maxSize`).

---

## 2) Parallax Layers

For any background/foreground group you want to drift subtly:

- Add **`Parallax2D`** to that GameObject.
- Assign `cameraTransform` (defaults to `Camera.main`).
- Set `strength`:
  - Background: negative (e.g., `-0.2`)
  - Foreground: small positive (e.g., `0.1`)
- Keep *Z* locked in sensible tiers (e.g., -6, -4, -2, 0, +2, +4) to retain 2D read and deterministic sorting.

---

## 3) Materials & Shaders

### Toon Ramp
- Create a Material using **`Isoplanar/ToonRamp`**.
- Generate a ramp via **`Isoplanar2D > Generate Toon Ramp (256x1)`**.
  - Assign **Generated_ToonRamp.png** to `_RampTex`.
- Tune:
  - `_RampStrength` (0→1) blends toon banding onto base.
  - `_ReceiveShadows` scales contribution from main light’s shadow map.
- Optional `_MainTex` supports flat UV color or low-frequency paint.

### Matcap Toon (optional)
- Create a Material using **`Isoplanar/MatcapToon`**.
- Generate matcap via **`Isoplanar2D > Generate Simple Matcap (256x256)`**.
- Assign to props/characters for a controlled “inked” highlight that doesn’t depend on scene lights.
- Use `_MatcapStrength` to mix with the base color/texture.

### Outlines (Inverted Hull)
- Duplicate the mesh (or add an additional material slot).
- Assign **`Isoplanar/OutlineInvertedHull`** material to the **back** (lower index) slot, the main toon to the **front** (higher index).
- Tweak `_Thickness` for stable outlines; keep it above sub-pixel at target resolution.
- This method is robust in orthographic and avoids screen-space wobble.

---

## 4) Posterize Post Pass (URP Renderer Feature)

1. Select your **URP Renderer Data** asset (e.g., *ForwardRenderer*).
2. Click **Add Renderer Feature** → **PosterizeRendererFeature** (appears if scripts compiled).
3. Set:
   - `Shader`: **Hidden/Isoplanar/Post/Posterize** (auto-assigned)
   - `Steps Per Channel`: 4–8 (fewer = bolder bands)
   - `Injection Point`: `AfterRenderingPostProcessing` (default)
4. Ensure camera is using this Renderer (check on the camera’s **Renderer** override if applicable).

Tip: Posterize works great with MSAA and no TAA, keeping silhouettes crisp without temporal ghosting.

---

## 5) Lighting Discipline

- Use **one Directional Light** for the scene key (fixed azimuth).
- Prefer **hard** shadows; clamp distance to prevent crawl.
- If you need soft fill, add a dim secondary light or use environment lighting at low intensity.
- Keep materials low-specular; iconic looks degrade with glossy micro-highlights.

---

## 6) Asset Production Rules

- **Value bands:** aim for 3–4 discrete lightness levels per palette.
- **Textures:** prefer flat color or large shapes; avoid micro-detail (it shimmers in ortho).
- **Transparency:** minimize; for compound sprites/props use `SortingGroup` and Z tiers to avoid sorting noise.
- **Shadows:** either use blob quads on a catcher plane or the toon ramp + main shadow map. Be consistent.

---

## 7) QA Checklist

- **Multiple resolutions:** test 720p and 1080p with TAA **off**; verify no texture crawl.
- **MSAA:** 2x/4x acceptable cost on desktop; confirm on your floor GPU.
- **Outline thickness:** never sub-pixel at smallest target resolution.
- **Ramp sanity:** confirm no banding flicker as camera pans (use clamp wrap & point filter on ramp).

---

## 8) Known Failure Modes (and fixes)

- **Shimmer on thin details** → remove micro-textures; raise mip bias (+0.5 to +1); reduce anisotropy; thicken forms.
- **Muddy look** → disable SSAO/TAA; increase posterize strength; reduce texture complexity.
- **Transparency sorting** → avoid overlapping alpha; quantize Z tiers; use `SortingGroup`.
- **Outline z-fighting** → increase outline thickness slightly or push mesh by normal; ensure outline renders before main (lower queue).

---

## 9) Extending

- Add a LUT grading pass (3D LUT) for palette enforcement if desired.
- For characters, you can bake skeletal animation to sprite sheets for perfect pixel lock while keeping 3D layouts.
- If you must hint depth, switch to Perspective with FOV 5–10° but **keep camera level** and only pan/zoom → preserves isoplanar motion.

---

## 10) Quick Start

1. Create new URP scene.
2. Add `IsoplanarCamera` to Main Camera (orthographic).
3. Add a few cubes/planes at Z tiers (-4, -2, 0, +2).
4. Generate `Generated_ToonRamp.png`, create a **ToonRamp** material, assign to meshes.
5. Add **PosterizeRendererFeature** to the Renderer.
6. Hit Play: pan with WASD, zoom with mouse; add `Parallax2D` to BG for drift.

You now have a 3D-authored, 2D-reading, strictly planar pipeline with bold, iconic rendering.

