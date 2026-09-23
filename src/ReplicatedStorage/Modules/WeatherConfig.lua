-- The Matterhorn's defining hazard isn't altitude sickness, it's the afternoon
-- thunderstorm that builds over the course of the day. Climbers do an "alpine
-- start" at 3-4am specifically to be off the summit and back at Hörnli Hut
-- before it hits. `stormClock` (0-100) drives WeatherController's state machine.

local WeatherConfig = {
	states = {
		Clear = {
			staminaDrainMultiplier = 1.0,
			rockfallRiskMultiplier = 1.0,
			visibility = 1.0,
		},
		Clouding = {
			staminaDrainMultiplier = 1.1,
			rockfallRiskMultiplier = 1.2,
			visibility = 0.7,
		},
		Windy = {
			staminaDrainMultiplier = 1.25,
			rockfallRiskMultiplier = 1.5,
			visibility = 0.6,
		},
		Thunderstorm = {
			staminaDrainMultiplier = 1.6,
			rockfallRiskMultiplier = 2.5,
			visibility = 0.25,
			lightningRisk = true,
		},
	},

	-- stormClock thresholds: below Clouding, at/above becomes that state.
	stormClockThresholds = {
		{ threshold = 0, state = "Clear" },
		{ threshold = 40, state = "Clouding" },
		{ threshold = 65, state = "Windy" },
		{ threshold = 85, state = "Thunderstorm" },
	},

	-- stormClock ticks up over real playtime; an early (alpine) start buys
	-- more clock before the storm threshold is reached.
	stormClockPerSecond = 0.15,
	alpineStartClockDiscount = 25, -- subtracted once if the player has a Headlamp when leaving Zermatt
}

return WeatherConfig
