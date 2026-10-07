# Matterhorn mesh

Source: ["Matterhorn mountain (Mount Cervinia) Switzerland"](https://sketchfab.com/3d-models/matterhorn-mountain-mount-cervinia-switzerland-dc08b8e992ed4ae8a89b77f63e38b9b5)
by LibanCiel (Sketchfab). Uploaded as a repo Release asset (`model` tag) and
decimated here for Roblox.

There are two versions of the mountain. Pick one:

- **`matterhorn.obj` — simple, one piece, lower detail.** A single MeshPart,
  decimated from the 1.29M-vertex/428,731-triangle source down to **15,000
  triangles** (quadric edge-collapse), since Roblox hard-caps a single
  MeshPart at 21,000 triangles. One import, one Size edit (below). Keeps
  the silhouette (the four ridges, the Hörnli/Zmutt/Furggen/Lion faces)
  intact at the distance players will actually see it from.
- **`full_res_parts/` — every triangle, 24 pieces.** The complete,
  undecimated mesh, split into 24 MeshParts (~17,864 triangles each) so
  none exceed Roblox's limit. Noticeably more detail up close, at the cost
  of 24 manual imports instead of 1. Its footprint is also narrower (X/Z
  squashed to 75% of this file's, same real height) -- see that folder's
  own README for exact import steps.
- `matterhorn.glb` — kept as a backup/reference; Studio does not import glTF
  natively as of this writing, so prefer the OBJ(s) above.

No baked photo textures existed in the source (flat/vertex-shaded materials
only), so nothing was lost there — apply a Roblox `Material` (Rock/Snow) or a
`SurfaceAppearance` in Studio after import rather than expecting a texture.

## Importing into Studio (single-piece `matterhorn.obj`)

For the full-resolution 24-part version instead, see `full_res_parts/README.md`.

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

## Placing the route's camp markers against the mesh

`Camps.lua` now models the real Hörnli Ridge waypoints (Schwarzsee, Hörnli
Hut, the lower broken ridge, Solvay Hut between the Moseley Slabs, the
Shoulder, the fixed ropes, the summit — see that file's header comment for
sources). To line each camp's checkpoint part up with the actual mesh
geometry at roughly the right height, assuming the mesh's own vertical
extent runs base-of-mountain to summit (check this by eye once it's
imported — if the model includes a wider skirt of surrounding terrain,
the real base will sit higher up the mesh's own bounding box than 0%):

| Camp | Altitude | Fraction up the mesh (0 = base, 1 = summit) |
|---|---|---|
| Zermatt | 1620 m | 0.000 (below the mesh entirely — it's the valley town) |
| Schwarzsee | 2583 m | 0.337 |
| Hörnli Hut | 3260 m | 0.574 |
| Hut Rocks (Lower Ridge) | 3600 m | 0.693 |
| Solvay Hut | 4003 m | 0.834 |
| The Shoulder | 4220 m | 0.910 |
| The Fixed Ropes | 4380 m | 0.966 |
| Summit | 4478 m | 1.000 |

`Y = meshBottomY + fraction * meshHeightInStuds`, where `meshBottomY` is
the MeshPart's lowest point after you've positioned it and `meshHeightInStuds`
is its `Size.Y` (2858 in both versions — the full-res parts only squash
X/Z, not Y). The Hörnli Hut and above should also sit on the mesh's actual
northeast ridge line, not just at the right height — nudge X/Z by eye so
the checkpoint parts trace that ridge. Note the full-res version's X/Z
footprint is narrower (75%) than this single-piece file's, so the same
absolute X/Z checkpoint coordinates won't carry over between the two —
re-eyeball placement if you switch versions.

Re-running the decimation at a different triangle budget (e.g. if 15K still
imports too slowly, or you want more detail up close) just needs the
original Release asset re-downloaded — see the repo's `model` release —
and `trimesh`'s `simplify_quadric_decimation(face_count=N)`.
