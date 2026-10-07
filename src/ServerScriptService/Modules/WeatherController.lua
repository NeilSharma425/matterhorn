local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherConfig = require(ReplicatedStorage.Modules.WeatherConfig)

local WeatherController = {}

local function stateForClock(clock)
	local chosen = WeatherConfig.stormClockThresholds[1].state
	for _, entry in ipairs(WeatherConfig.stormClockThresholds) do
		if clock >= entry.threshold then
			chosen = entry.state
		end
	end
	return chosen
end

-- Real alpine starts (leaving Hörnli Hut ~3:30-4:30am, in the dark) are what
-- buy climbers the daylight margin before afternoon storms -- without a
-- Headlamp you couldn't actually have left in the dark, so the clock starts
-- with a chunk of that margin already burned. CampController calls this
-- once, exactly when the player departs Hörnli Hut for the summit push.
function WeatherController.ApplyAlpineStartTiming(profile)
	profile.stormClock = profile.gear.Headlamp and 0 or WeatherConfig.lateStartPenalty
end

-- The storm clock models the summit-day push specifically, not the
-- gear-up/approach the day before -- it only starts ticking once the player
-- has left Hörnli Hut (profile.hutDepartureRealTime gets set at that exact
-- moment by CampController.Advance).
function WeatherController.Update(profile, dt)
	if not profile.alive or not profile.hutDepartureRealTime then
		return false
	end

	profile.stormClock = math.min(100, profile.stormClock + WeatherConfig.stormClockPerSecond * dt)

	local newState = stateForClock(profile.stormClock)
	if newState ~= profile.weatherState then
		profile.weatherState = newState
		return true -- caller should fire WeatherChanged
	end
	return false
end

function WeatherController.GetStateConfig(profile)
	return WeatherConfig.states[profile.weatherState]
end

return WeatherController
