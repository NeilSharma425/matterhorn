local Constants = {
	StartingMoney = 150,

	MaxStamina = 100,
	MaxHealth = 100,
	MaxFocus = 100, -- drains on technical scrambling above Hörnli Hut; 0 focus = slip risk spikes

	PassiveStaminaRegenAtCamp = 8, -- per "rest" action
	PassiveFocusRegenAtCamp = 15,

	BaseStaminaDrainPerMove = 3,
	BaseFocusDrainPerMove = 2, -- only applied on camps with technicalDifficulty > 0.3

	RiskEventCheckIntervalSeconds = 20,

	StatUpdateThrottleSeconds = 1,

	RiskEvents = {
		Rockfall = {
			baseChance = 0.05, -- scaled by camp.rockfallRisk and weather.rockfallRiskMultiplier
			damage = { min = 15, max = 35 },
			message = "Rockfall! Loose stone comes down off the ridge.",
		},
		Slip = {
			baseChance = 0.04, -- scaled by camp.technicalDifficulty, reduced by Crampons/IceAxe
			damage = { min = 10, max = 25 },
			message = "Your foot slips on the exposed scramble.",
		},
		Lightning = {
			baseChance = 0.10, -- only checked when weather.lightningRisk is true and above Hörnli Hut
			damage = { min = 30, max = 60 },
			message = "Lightning strikes near the ridge -- you need to get down NOW.",
		},
		Fatigue = {
			baseChance = 0.03, -- scaled by (1 - stamina/MaxStamina)
			damage = { min = 5, max = 15 },
			message = "Exhaustion catches up with you.",
		},
	},
}

return Constants
