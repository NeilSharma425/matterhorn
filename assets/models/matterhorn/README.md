# Matterhorn mesh

Source: ["Matterhorn mountain (Mount Cervinia) Switzerland"](https://sketchfab.com/3d-models/matterhorn-mountain-mount-cervinia-switzerland-dc08b8e992ed4ae8a89b77f63e38b9b5)
by LibanCiel (Sketchfab). Uploaded as a repo Release asset (`model` tag) and
decimated here for Roblox.

- `matterhorn.obj` — use this one. Roblox Studio's Bulk Import (Avatar tab →
  Import 3D, or drag into the 3D Viewport/Explorer) reads OBJ directly.
- `matterhorn.glb` — kept as a backup/reference; Studio does not import glTF
  natively as of this writing, so prefer the OBJ.

Original mesh was 1.29M vertices / 428,731 triangles — far past what a single
Roblox MeshPart should carry (practical ceiling is ~10-20K triangles; more
than that tanks import reliability and in-game frame time). It's been
decimated with quadric edge-collapse to **15,000 triangles**, which keeps the
silhouette (the four ridges, the Hörnli/Zmutt/Furggen/Lion faces) intact at
the distance players will actually see it from.

No baked photo textures existed in the source (flat/vertex-shaded materials
only), so nothing was lost there — apply a Roblox `Material` (Rock/Snow) or a
`SurfaceAppearance` in Studio after import rather than expecting a texture.

## Importing into Studio

1. Avatar tab → **Import 3D** → select `matterhorn.obj`.
2. It imports as a single MeshPart. Rename it `MatterhornMesh`.
3. Set its **Size** to match the real mountain's proportions. Zermatt sits at
   1620m and the summit is at 4478m, a relief of 2858m; the raw mesh's
   bounding box is (49.9 x, 19.5 y, 50.4 z) in its own units, so scaling to
   real-world meters-as-studs (1 stud = 1 meter) gives:

   ```
   Size = (7165, 2858, 7386)   -- (X, Y, Z) in studs
   ```

   Set Size directly in the Properties panel rather than dragging resize
   handles, so the three axes scale independently to hit this box exactly.
4. Position it so the **base sits at the same baseplate Y as the Zermatt camp
   part** in the route (see `src/ReplicatedStorage/Modules/Camps.lua`), and
   so the actual summit point of the mesh lines up above wherever the
   `Summit` camp checkpoint part is placed. You'll likely nudge X/Z once by
   eye until the ridge the Hörnli Hut/Solvay Hut checkpoints sit on lines up
   with the mesh's real Hörnli ridge line (the northeast ridge).
5. Set `Anchored = true`, `CanCollide = true` (players climb on this),
   `CastShadow = true`.
6. Apply a `Material` (try `Rock` low down, `Snow`/`Ice` — or a second
   thin MeshPart cap — above ~4000m) for texture without needing an image.

Re-running the decimation at a different triangle budget (e.g. if 15K still
imports too slowly, or you want more detail up close) just needs the
original Release asset re-downloaded — see the repo's `model` release —
and `trimesh`'s `simplify_quadric_decimation(face_count=N)`.
