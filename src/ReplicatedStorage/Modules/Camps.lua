-- The real Hörnli Ridge route (standard Matterhorn line), researched from
-- SummitPost's Hörnligrat/Solvay Hut pages and guide-service route notes
-- (Blackbird Guides, 57hours, Alpine Ascents). Sources noted per field where
-- it isn't common knowledge.
--
-- Key real numbers this data is built from:
--   Hörnli Hut: 3260m. Solvay Hut: 4003m (743m above the hut, 475m below
--   the summit), on a ledge between the Lower and Upper Moseley Slabs.
--   Summit: 4478m. Hut->Solvay target: 2-2.5h, with a hard "turn around if
--   you're not there within 2.5-3h" rule. Hut->Summit target 4.5-5.5h, and
--   descent back to the hut is *also* 4.5-5.5h via the same ridge -- there
--   is no separate descent route. Most of the ~1-in-415 fatal outcomes on
--   this route happen on the way down, not the way up.
--
-- `legHours` is the real guidebook time for the leg *above* this camp (i.e.
-- the hours to climb from this camp to the next one on the way up); it's
-- used to calibrate staminaCostToReach, and -- scaled by
-- Constants.RouteCompressionSecondsPerRealHour below -- `targetSeconds` is
-- how long that same leg should take to physically walk in-game. The real
-- route sums to 8 hours door-to-door (Zermatt to summit); compressed to a
-- 1-hour play session, every camp's targetSeconds adds up to exactly 3600.
-- This is the number to build each leg's actual walking path against (see
-- assets/models/matterhorn/README.md) -- and the server logs each leg's
-- real elapsed time against this target as you playtest, so you can tune
-- path length/switchbacks until it matches.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)

local function compress(legHours)
	return legHours * Constants.RouteCompressionSecondsPerRealHour
end

local Camps = {
	{
		id = "Zermatt",
		name = "Zermatt (Start)",
		altitude = 1620,
		description = "The valley town at the foot of the mountain. Buy gear here before setting off.",
		requiredGear = {},
		rockfallRisk = 0,
		technicalDifficulty = 0,
		staminaCostToReach = 0,
		legHours = 0.75, -- walk/cable car up to Schwarzsee
		targetSeconds = compress(0.75), -- 337.5s
		hasShop = true,
	},
	{
		id = "Schwarzsee",
		name = "Schwarzsee",
		altitude = 2583,
		description = "Cable car station and trailhead. From here it's foot travel the rest of the way.",
		requiredGear = {},
		rockfallRisk = 0.02,
		technicalDifficulty = 0.1,
		staminaCostToReach = 5,
		legHours = 2.25, -- ~2-2.5h marked trail to the hut
		targetSeconds = compress(2.25), -- 1012.5s
	},
	{
		id = "HornliHut",
		name = "Hörnli Hut",
		altitude = 3260,
		description = "Base for the summit push, built in 1880. Climbers leave around 3:30-4:30am to be off the ridge before the afternoon storms build.",
		requiredGear = { "Helmet", "Harness" },
		rockfallRisk = 0.05,
		technicalDifficulty = 0.2,
		staminaCostToReach = 14,
		legHours = 1.25, -- fast scrambling through the lower broken rock
		targetSeconds = compress(1.25), -- 562.5s
		hasShop = true, -- at hut markup -- see GearConfig
	},
	{
		id = "LowerRidge",
		name = "Hut Rocks (Lower Ridge)",
		altitude = 3600,
		description = "Broken 4th-class terrain right above the hut. Easier climbing than what's above, but it's where most parties are stacked up, so loose-rock risk from climbers overhead is highest here. The disciplined move is to move fast through it.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe" },
		rockfallRisk = 0.12,
		technicalDifficulty = 0.35,
		staminaCostToReach = 18,
		legHours = 1.0,
		targetSeconds = compress(1.0), -- 450s
	},
	{
		id = "SolvayHut",
		name = "Solvay Hut",
		altitude = 4003,
		description = "A 10-person emergency bivouac on a ledge between the Lower and Upper Moseley Slabs -- the highest hut on the mountain. If you haven't reached it within about 3 hours of leaving Hörnli Hut, the disciplined move is to turn back.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe" },
		rockfallRisk = 0.1,
		technicalDifficulty = 0.4, -- the Moseley Slab, graded III-
		staminaCostToReach = 14,
		legHours = 1.5, -- Upper Moseley Slab back to the ridge crest, up to the Shoulder
		targetSeconds = compress(1.5), -- 675s
		isEmergencyShelter = true,
		isTurnaroundCheckpoint = true,
	},
	{
		id = "Shoulder",
		name = "The Shoulder",
		altitude = 4220,
		description = "Where the ridge crest meets the start of the fixed ropes. Exposed snow arête with real fall consequences on either side.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe", "Rope" },
		rockfallRisk = 0.08,
		technicalDifficulty = 0.55,
		staminaCostToReach = 21,
		legHours = 0.75, -- the fixed-rope headwall
		targetSeconds = compress(0.75), -- 337.5s
	},
	{
		id = "FixedRopes",
		name = "The Fixed Ropes",
		altitude = 4380,
		description = "The steepest pitch on the route, climbed on or near the old fixed ropes bolted to the rock. Above this it's just the final slopes to the top.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe", "Rope" },
		rockfallRisk = 0.1,
		technicalDifficulty = 0.65,
		staminaCostToReach = 11,
		legHours = 0.5,
		targetSeconds = compress(0.5), -- 225s
	},
	{
		id = "Summit",
		name = "Summit",
		altitude = 4478,
		description = "The Swiss summit. The slightly lower Italian summit sits a short, narrow, corniced traverse away. Getting back down to the hut -- same ridge, same fixed ropes, now tired -- is the part that actually kills people.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe", "Rope" },
		rockfallRisk = 0.12,
		technicalDifficulty = 0.7,
		staminaCostToReach = 7,
		legHours = 0,
		targetSeconds = 0,
	},
}

return Camps
