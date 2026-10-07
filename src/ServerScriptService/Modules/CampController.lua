local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camps = require(ReplicatedStorage.Modules.Camps)
local GearConfig = require(ReplicatedStorage.Modules.GearConfig)
local Constants = require(ReplicatedStorage.Modules.Constants)

local PlayerDataManager = require(script.Parent.PlayerDataManager)
local WeatherController = require(script.Parent.WeatherController)

local CampController = {}

local GearById = {}
for _, gear in ipairs(GearConfig) do
	GearById[gear.id] = gear
end

local function hasRequiredGear(profile, camp)
	for _, gearId in ipairs(camp.requiredGear) do
		if not profile.gear[gearId] then
			return false, gearId
		end
	end
	return true
end

function CampController.GetCamp(index)
	return Camps[index]
end

-- Moving toward the summit. Only valid while still ascending.
function CampController.Advance(player)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return false, "not alive"
	end
	if not profile.ascending then
		return false, "already descending -- the route back down is the same ridge"
	end

	local nextIndex = profile.campIndex + 1
	if nextIndex > #Camps then
		return false, "already at the summit"
	end

	local currentCamp = Camps[profile.campIndex]
	local nextCamp = Camps[nextIndex]

	local okGear, missingGear = hasRequiredGear(profile, nextCamp)
	if not okGear then
		return false, "missing gear: " .. missingGear
	end

	if profile.stamina < nextCamp.staminaCostToReach then
		return false, "too exhausted for this leg -- rest first"
	end

	profile.stamina -= nextCamp.staminaCostToReach
	if nextCamp.technicalDifficulty > 0.3 then
		profile.focus -= Constants.BaseFocusDrainPerMove * (1 + nextCamp.technicalDifficulty)
	end

	-- The real alpine start: leaving Hörnli Hut in the dark for the summit
	-- push. This is the one moment that starts the storm clock and the
	-- Solvay turnaround timer.
	if currentCamp.id == "HornliHut" then
		profile.hutDepartureRealTime = os.clock()
		WeatherController.ApplyAlpineStartTiming(profile)
	end

	-- How long that leg actually took to walk, vs. the real-route-derived
	-- target (Camps.lua targetSeconds) -- this is the stopwatch for tuning
	-- checkpoint spacing/WalkSpeed in Studio against the 1-hour design goal.
	local elapsedSeconds = os.clock() - profile.legStartRealTime
	profile.legStartRealTime = os.clock()

	profile.campIndex = nextIndex
	profile.bestCampReached = math.max(profile.bestCampReached, nextIndex)

	if nextIndex == #Camps then
		-- Summited. From here every remaining move is a descent down the
		-- same ridge -- there is no other way off this mountain.
		profile.ascending = false
	end

	PlayerDataManager.Clamp(profile)
	return true, {
		camp = nextCamp,
		elapsedSeconds = elapsedSeconds,
		targetSeconds = currentCamp.targetSeconds,
	}
end

-- Moving away from the summit, down the same ridge. Also how a player
-- aborts early (e.g. overdue at Solvay) -- any backward move commits to
-- descending for the rest of the expedition, same as a real retreat.
function CampController.Retreat(player)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return false, "not alive"
	end

	local prevIndex = profile.campIndex - 1
	if prevIndex < 1 then
		return false, "already back at Zermatt"
	end

	local legCamp = Camps[profile.campIndex] -- the leg being downclimbed
	profile.ascending = false

	local descentStaminaFactor = 0.6 -- downclimbing costs less stamina than climbing, but isn't free
	profile.stamina -= legCamp.staminaCostToReach * descentStaminaFactor

	profile.campIndex = prevIndex
	PlayerDataManager.Clamp(profile)
	return true, Camps[prevIndex]
end

function CampController.Rest(player)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return false, "not alive"
	end

	profile.stamina += Constants.PassiveStaminaRegenAtCamp
	profile.focus += Constants.PassiveFocusRegenAtCamp
	profile.stormClock = math.min(100, profile.stormClock + Constants.RestStormClockCost)
	PlayerDataManager.Clamp(profile)
	return true, { stamina = profile.stamina, focus = profile.focus }
end

function CampController.BuyGear(player, gearId)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return false, "not alive"
	end

	local camp = Camps[profile.campIndex]
	if not camp.hasShop then
		return false, "no shop here"
	end

	local gear = GearById[gearId]
	if not gear then
		return false, "no such gear"
	end
	if profile.gear[gearId] then
		return false, "already own this"
	end

	local cost = gear.cost
	if camp.id ~= "Zermatt" then
		cost = math.floor(cost * Constants.HutShopMarkup)
	end

	if profile.money < cost then
		return false, "can't afford it"
	end

	profile.money -= cost
	profile.gear[gearId] = true
	return true, { gearId = gearId, cost = cost }
end

return CampController
