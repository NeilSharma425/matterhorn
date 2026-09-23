-- Gear purchasable at Zermatt (or Hörnli Hut, at a markup). Required gear gates
-- camp progression -- see Camps.lua `requiredGear`.

local GearConfig = {
	{ id = "Helmet", name = "Climbing Helmet", cost = 40, reducesRockfallDamage = 0.5 },
	{ id = "Harness", name = "Climbing Harness", cost = 60, reducesFallDamage = 0.5 },
	{ id = "Crampons", name = "Crampons", cost = 90, reducesSlipChance = 0.6 },
	{ id = "IceAxe", name = "Ice Axe", cost = 70, reducesSlipChance = 0.3 },
	{ id = "Rope", name = "Climbing Rope", cost = 100, reducesFallDamage = 0.3 },
	{ id = "Headlamp", name = "Headlamp", cost = 25, enablesAlpineStart = true },
	{ id = "InsulatedJacket", name = "Insulated Jacket", cost = 55, reducesStaminaDrain = 0.15 },
}

return GearConfig
