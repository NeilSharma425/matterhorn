local DataStoreService = game:GetService("DataStoreService")

local Constants = game:GetService("ReplicatedStorage").Modules.Constants
Constants = require(Constants)

local ProgressStore = DataStoreService:GetDataStore("MatterhornProgress_v1")

local PlayerDataManager = {}
PlayerDataManager._profiles = {} -- [userId] = profile

local function defaultProfile()
	return {
		stamina = Constants.MaxStamina,
		health = Constants.MaxHealth,
		focus = Constants.MaxFocus,
		money = Constants.StartingMoney,
		campIndex = 1, -- index into Camps.lua, 1 = Zermatt
		gear = {}, -- set: gearId -> true
		alive = true,
		stormClock = 0,
		weatherState = "Clear",
		bestCampReached = 1,
		ascending = true, -- false once the player turns around from the summit (or retreats early)
		hutDepartureRealTime = nil, -- os.clock() when they left Hörnli Hut; drives the storm clock + Solvay turnaround rule
		legStartRealTime = os.clock(), -- os.clock() when they entered the current camp; for the per-leg timing stopwatch
	}
end

function PlayerDataManager.Load(player)
	local profile = defaultProfile()

	local ok, saved = pcall(function()
		return ProgressStore:GetAsync("Player_" .. player.UserId)
	end)

	if ok and typeof(saved) == "table" then
		profile.money = saved.money or profile.money
		profile.gear = saved.gear or profile.gear
		profile.bestCampReached = saved.bestCampReached or profile.bestCampReached
	elseif not ok then
		warn(("MatterhornProgress: failed to load data for %s: %s"):format(player.Name, tostring(saved)))
	end

	PlayerDataManager._profiles[player.UserId] = profile
	return profile
end

function PlayerDataManager.Get(player)
	return PlayerDataManager._profiles[player.UserId]
end

function PlayerDataManager.Save(player)
	local profile = PlayerDataManager._profiles[player.UserId]
	if not profile then
		return
	end

	local ok, err = pcall(function()
		ProgressStore:SetAsync("Player_" .. player.UserId, {
			money = profile.money,
			gear = profile.gear,
			bestCampReached = profile.bestCampReached,
		})
	end)

	if not ok then
		warn(("MatterhornProgress: failed to save data for %s: %s"):format(player.Name, tostring(err)))
	end
end

function PlayerDataManager.Remove(player)
	PlayerDataManager.Save(player)
	PlayerDataManager._profiles[player.UserId] = nil
end

-- A failed attempt doesn't erase gear or money -- it just sends the
-- climber back to Zermatt for another go, same as how an unsuccessful (or
-- aborted) real expedition just means trying again another day.
function PlayerDataManager.ResetExpedition(profile)
	profile.stamina = Constants.MaxStamina
	profile.health = Constants.MaxHealth
	profile.focus = Constants.MaxFocus
	profile.campIndex = 1
	profile.alive = true
	profile.stormClock = 0
	profile.weatherState = "Clear"
	profile.ascending = true
	profile.hutDepartureRealTime = nil
	profile.legStartRealTime = os.clock()
end

function PlayerDataManager.Clamp(profile)
	profile.stamina = math.clamp(profile.stamina, 0, Constants.MaxStamina)
	profile.health = math.clamp(profile.health, 0, Constants.MaxHealth)
	profile.focus = math.clamp(profile.focus, 0, Constants.MaxFocus)
	profile.money = math.max(profile.money, 0)
end

return PlayerDataManager
