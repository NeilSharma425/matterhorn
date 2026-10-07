# Full-resolution mountain (all 428,731 triangles, split into 24 parts)

Roblox caps a single `MeshPart` at 21,000 triangles, so the complete source
mesh (428,731 triangles, no decimation -- every triangle from the original
Sketchfab model) is split into 24 vertical slabs (`matterhorn_part_01.obj`
through `_24.obj`), each ~17,864 triangles. See `manifest.json` for the
exact per-part triangle count and bounding box.

Unlike the single-piece `../matterhorn.obj`, **the scale and position are
already baked into these files' vertex coordinates** -- studs, not the
mesh's native units, with X/Z squashed to 75% of the single-piece version's
footprint while Y (height) stays at the real 2858-stud relief (per request:
narrower base, same real height). You do not need to compute or type a
Size value.

Overall assembled size: **5351 x 2858 x 5516 studs** (X, Y, Z). The mountain
is centered at X=0, Z=0, with its base at Y=0.

## Importing all 24 parts

1. Avatar tab (or File menu) → **Import 3D** → select `matterhorn_part_01.obj`.
2. Immediately after it lands in Workspace, select it and set:
   - **Position** = `0, 0, 0`
   - **Orientation** = `0, 0, 0`
   - **Anchored** = true, **CanCollide** = true
   - Leave **Size** alone -- it should already auto-match the `size` value
     `manifest.json` lists for that file. If it doesn't (some Studio
     versions apply their own default import scale), type in the exact
     `size` from the manifest for that part.
3. Repeat for all 24 files. Because every part shares the same baked-in
   coordinate system and you're setting the same Position (0,0,0) on all of
   them, they'll assemble into a single seamless mountain automatically --
   no manual alignment between pieces.
4. Once all 24 are in, select them all in Explorer and group them
   (**Ctrl+G** / right-click → Group) into one Model named `MatterhornMesh`
   for convenience (moving/renaming the mountain as a unit, applying
   Material to all pieces at once, etc).
5. Apply a `Material` (Rock low down, Snow/Ice higher up) same as the
   single-piece version.

This is materially more manual work than the single `matterhorn.obj` (24
imports + Position-setting vs. 1 import + 1 Size edit) in exchange for the
mountain's actual full detail rather than a 15K-triangle decimation.
Studio will also be slower to work with 24 separate parts vs. one -- group
them as soon as you're done importing.

## Regenerating with a different split

If you want fewer/more parts (trading off per-part detail vs. import
tedium), or a different X/Z squash factor, the split was produced by a
script against the repo's `model` GitHub Release asset (the original,
undecimated `.glb`) using `trimesh`, slicing the mesh into N balanced
vertical strips along X sorted by face centroid, each scaled by
`scaleXZ`/`scaleY` from `manifest.json`. Ask for a regenerate with new
parameters rather than hand-editing the OBJs.
