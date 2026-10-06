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

-- Real alpine starts (leaving Hörnli Hut ~3:30-4:30am, in the dark) buy
-- climbers most of the daylight margin before afternoon storms. Headlamp
-- gear represents having actually done the alpine start; CampController
-- calls this once, exactly when the player departs Hörnli Hut for the
-- summit push.
function WeatherController.ApplyAlpineStartDiscount(profile)
	if profile.gear.Headlamp then
		profile.stormClock = math.max(0, profile.stormClock - WeatherConfig.alpineStartClockDiscount)
	end
end

function WeatherController.Update(profile, dt)
	if not profile.alive then
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
