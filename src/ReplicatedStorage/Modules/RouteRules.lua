-- Rules that come from how the real route is actually climbed, rather than
-- from any single camp's stats.

local WeatherConfig = require(game:GetService("ReplicatedStorage").Modules.WeatherConfig)

local RouteRules = {
	-- Real rule: if you haven't reached Solvay Hut within ~2.5-3h of leaving
	-- Hörnli Hut, turn back -- you're too slow to be off the ridge before
	-- the afternoon storm. We don't have literal hours in-game; what we have
	-- is stormClock (0 = Clear at the alpine start, 85 = Thunderstorm). The
	-- Thunderstorm threshold represents roughly the ~9-10h of daylight
	-- margin a real alpine start buys you, so 3h of that is ~27-30% of the
	-- 0-85 budget. We use the stricter (earlier) end of the real guidance.
	SolvayTurnaroundClockDelta = 0.27 * WeatherConfig.stormClockThresholds[4].threshold, -- Thunderstorm threshold

	-- There is no separate descent route on the Matterhorn -- you downclimb
	-- the same ridge you went up. Most of the route's fatal outcomes happen
	-- here: afternoon sun loosens rock that was frozen solid at the alpine
	-- start, and climbers are fatigued after a 4.5-5.5h push to the summit.
	DescentRockfallMultiplier = 1.6,
	DescentFatigueChanceMultiplier = 2.0,

	-- Being overdue at the Solvay checkpoint doesn't hard-fail the climb --
	-- it escalates real danger the way pushing on past the turnaround time
	-- actually does, by compounding with whatever weather is already doing.
	OverdueRiskMultiplier = 1.5,
}

function RouteRules.IsOverdueAtSolvay(profile, stormClockAtHutDeparture)
	if profile.ascending == false then
		return false
	end
	if stormClockAtHutDeparture == nil then
		return false
	end
	return (profile.stormClock - stormClockAtHutDeparture) > RouteRules.SolvayTurnaroundClockDelta
end

return RouteRules
