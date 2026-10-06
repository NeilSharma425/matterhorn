# Matterhorn

A Roblox climbing simulator on the real Hörnli Ridge route — the standard
line up the Matterhorn from Zermatt. Built as a Rojo project: the Luau code
lives in `src/`, synced into Roblox Studio.

## What's modeled, and from where

Route data (`src/ReplicatedStorage/Modules/Camps.lua`) is built from the
real route, researched from SummitPost's Hörnligrat and Solvay Hut pages
and guide-service route notes (Blackbird Guides, 57hours, Alpine Ascents):

- **Hörnli Hut** (3260m) → **Hut Rocks / Lower Ridge** (broken 4th-class
  terrain, fastest-moving section, worst rockfall from parties stacked up
  above you) → **Solvay Hut** (4003m, the highest hut on the mountain, on a
  ledge between the Lower and Upper Moseley Slabs) → **the Shoulder**
  (~4220m, where the fixed ropes start) → **the Fixed Ropes** (~4380m, the
  steepest pitch) → **Summit** (4478m).
- The real "turn around if you haven't reached Solvay within ~3h of
  leaving the hut" rule is modeled in `RouteRules.lua` as an escalating
  risk multiplier rather than a hard fail — push on past it and your odds
  get worse, same as in reality.
- **There is no separate descent route.** You downclimb the exact ridge you
  climbed. `CampController.Retreat` and the `DescentRockfallMultiplier` /
  `DescentFatigueChanceMultiplier` in `RouteRules.lua` reflect why most of
  the route's real fatal outcomes happen on the way down: afternoon sun
  loosens rock that was frozen at the alpine start, and you're climbing it
  tired.
- The storm-clock weather system (`WeatherConfig.lua`) stands in for the
  real defining hazard — not altitude sickness (the summit is only 4478m),
  but the afternoon thunderstorm buildup that alpine starts (leaving the
  hut ~3:30-4:30am) are specifically timed to beat.

## Project layout

```
default.project.json          Rojo mapping to Roblox services
src/ReplicatedStorage/Modules  Shared config: Camps, GearConfig, WeatherConfig, RouteRules, Constants
src/ServerScriptService        Server-authoritative game logic (Main.server.lua + Modules/)
src/StarterPlayer              Client HUD
assets/models/matterhorn       The real Matterhorn mesh + Studio import instructions
```

## Setting it up in Studio

1. Install [Rojo](https://rojo.space/) (CLI + the Studio plugin).
2. From the repo root: `rojo serve`.
3. In Studio, open the Rojo plugin panel and connect to the running server —
   this syncs in all the code and creates the `Remotes` folder.
4. Import the mountain mesh: follow
   `assets/models/matterhorn/README.md` (Studio's Import 3D on the `.obj`,
   then the exact Size/placement math is in that file).
5. Place a checkpoint `Part` for each camp in `Camps.lua` (by `id`) along
   the ridge, roughly per the height-fraction table in the mesh README.
6. Hit Play. The HUD (stamina/health/focus/money, weather, Advance/Retreat/
   Rest/Gear Shop buttons) is built entirely in `ClientMain.client.lua` —
   no Studio GUI setup needed.

Player progress (money, gear owned, best camp reached) persists via
`DataStoreService`, which only works once the place is published (Studio
Play-solo without API Services enabled will just log a harmless warning and
fall back to in-memory defaults).
