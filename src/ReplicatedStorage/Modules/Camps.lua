-- Route stages up the Hörnli Ridge, the standard Matterhorn tourist route.
-- `requiredGear` gates progression; `rockfallRisk`/`technicalDifficulty` feed RiskEventController.

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
	},
	{
		id = "Schwarzsee",
		name = "Schwarzsee",
		altitude = 2583,
		description = "A gentle hike up from Zermatt on a marked trail.",
		requiredGear = {},
		rockfallRisk = 0.02,
		technicalDifficulty = 0.1,
		staminaCostToReach = 15,
	},
	{
		id = "HornliHut",
		name = "Hörnli Hut",
		altitude = 3260,
		description = "Base for the summit push. Climbers sleep here and leave around 3-4am to beat the afternoon storms.",
		requiredGear = { "Helmet", "Harness" },
		rockfallRisk = 0.05,
		technicalDifficulty = 0.2,
		staminaCostToReach = 20,
	},
	{
		id = "SolvayHut",
		name = "Solvay Hut",
		altitude = 4003,
		description = "A tiny emergency bivouac bolted to the ridge. The route above is exposed scrambling with fixed ropes.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe" },
		rockfallRisk = 0.15,
		technicalDifficulty = 0.5,
		staminaCostToReach = 30,
	},
	{
		id = "Summit",
		name = "Summit",
		altitude = 4478,
		description = "The top of the Matterhorn. Getting down before the storm rolls in is the real challenge.",
		requiredGear = { "Helmet", "Harness", "Crampons", "IceAxe", "Rope" },
		rockfallRisk = 0.2,
		technicalDifficulty = 0.7,
		staminaCostToReach = 25,
	},
}

return Camps
