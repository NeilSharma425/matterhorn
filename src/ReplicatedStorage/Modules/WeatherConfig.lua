-- The Matterhorn's defining hazard isn't altitude sickness, it's the afternoon
-- thunderstorm that builds over the course of the day. Climbers do an "alpine
-- start" at 3-4am specifically to be off the summit and back at Hörnli Hut
-- before it hits. `stormClock` (0-100) drives WeatherController's state
-- machine, and only starts ticking once the player actually leaves the hut
-- (see WeatherController.Update) -- the real storm clock is about the
-- summit-day push, not the gear-up/approach the day before.

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

	-- A real alpine start buys climbers roughly 9-9.5 daylight hours before
	-- afternoon storms are common. Compressed by the same
	-- RouteCompressionSecondsPerRealHour (450s/real-hour) used for camp
	-- travel times, that's ~4275 real-world-seconds of game time to reach
	-- the Thunderstorm threshold (85) -- so stormClockPerSecond is tuned so
	-- 85/stormClockPerSecond == 4275.
	--
	-- Compressed Hut->Summit travel time is 2250s (5h), so an on-pace
	-- climber summits with the clock around 45 -- comfortable margin, same
	-- as in reality: most parties who keep pace don't get caught. The
	-- Solvay turnaround rule (RouteRules.lua) is the mechanism that catches
	-- a party moving too slowly to be safe, well before weather does.
	stormClockPerSecond = 85 / 4275, -- ~0.01988/s

	-- Not doing a proper alpine start (no Headlamp) means a late start and
	-- a chunk of that daylight margin lost before you even leave the hut --
	-- applied once, as a starting offset, when WeatherController begins
	-- ticking the clock.
	lateStartPenalty = 20,
}

return WeatherConfig
