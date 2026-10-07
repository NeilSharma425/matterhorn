-- Rules that come from how the real route is actually climbed, rather than
-- from any single camp's stats.

local Constants = require(game:GetService("ReplicatedStorage").Modules.Constants)

local RouteRules = {
	-- Real rule: if you haven't reached Solvay Hut within ~2.5-3h of leaving
	-- Hörnli Hut, turn back -- you're too slow to be off the ridge before
	-- the afternoon storm. We use real elapsed play-seconds since hut
	-- departure against the same compression (450 game-seconds per
	-- real-hour) everything else uses, picking the stricter (earlier) end
	-- of the real 2.5-3h guidance.
	SolvayTurnaroundSeconds = 3 * Constants.RouteCompressionSecondsPerRealHour, -- 1350s

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

function RouteRules.IsOverdueAtSolvay(profile)
	if not profile.ascending or not profile.hutDepartureRealTime then
		return false
	end
	return (os.clock() - profile.hutDepartureRealTime) > RouteRules.SolvayTurnaroundSeconds
end

return RouteRules
