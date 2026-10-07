local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Modules.Constants)

local PlayerDataManager = require(script.Parent.Modules.PlayerDataManager)
local WeatherController = require(script.Parent.Modules.WeatherController)
local RiskEventController = require(script.Parent.Modules.RiskEventController)
local CampController = require(script.Parent.Modules.CampController)
local CheckpointController = require(script.Parent.Modules.CheckpointController)
local StatsBroadcaster = require(script.Parent.Modules.StatsBroadcaster)

local Remotes = ReplicatedStorage.Remotes
local WeatherChanged = Remotes.WeatherChanged
local RiskEvent = Remotes.RiskEvent
local GameLog = Remotes.GameLog
local RestAtCamp = Remotes.RestAtCamp
local BuyGear = Remotes.BuyGear

CheckpointController.Setup()

Players.PlayerAdded:Connect(function(player)
	local profile = PlayerDataManager.Load(player)
	StatsBroadcaster.Push(player, profile)
	GameLog:FireClient(player, "Welcome to Zermatt. Gear up, then walk for the Hörnli Hut.")
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerDataManager.Remove(player)
end)

RestAtCamp.OnServerInvoke = function(player)
	local ok, result = CampController.Rest(player)
	local profile = PlayerDataManager.Get(player)
	if profile then
		StatsBroadcaster.Push(player, profile)
	end
	return ok, result
end

BuyGear.OnServerInvoke = function(player, gearId)
	if type(gearId) ~= "string" then
		return false, "invalid gear id"
	end
	local ok, result = CampController.BuyGear(player, gearId)
	local profile = PlayerDataManager.Get(player)
	if profile then
		StatsBroadcaster.Push(player, profile)
	end
	return ok, result
end

local riskCheckAccumulator = {}
local statPushAccumulator = {}
local deathAccumulator = {}
local saveAccumulator = 0

local RESPAWN_DELAY_SECONDS = 6

RunService.Heartbeat:Connect(function(dt)
	for _, player in ipairs(Players:GetPlayers()) do
		local profile = PlayerDataManager.Get(player)
		if profile and not profile.alive then
			deathAccumulator[player] = (deathAccumulator[player] or 0) + dt
			if deathAccumulator[player] >= RESPAWN_DELAY_SECONDS then
				deathAccumulator[player] = 0
				PlayerDataManager.ResetExpedition(profile)
				StatsBroadcaster.Push(player, profile)
				GameLog:FireClient(player, "Back in Zermatt. Ready for another attempt.")
			end
		end
		if profile and profile.alive then
			local weatherChanged = WeatherController.Update(profile, dt)
			if weatherChanged then
				WeatherChanged:FireClient(player, profile.weatherState)
			end

			riskCheckAccumulator[player] = (riskCheckAccumulator[player] or 0) + dt
			if riskCheckAccumulator[player] >= Constants.RiskEventCheckIntervalSeconds then
				riskCheckAccumulator[player] = 0
				local events, overdue = RiskEventController.Check(player)
				for _, event in ipairs(events) do
					RiskEvent:FireClient(player, event)
				end
				if overdue then
					GameLog:FireClient(player, "You're overdue at Solvay Hut's turnaround time -- the longer you push on, the worse your odds.")
				end
				if not profile.alive then
					GameLog:FireClient(player, "You didn't make it down. A new attempt starts back in Zermatt.")
				end
			end

			statPushAccumulator[player] = (statPushAccumulator[player] or 0) + dt
			if statPushAccumulator[player] >= Constants.StatUpdateThrottleSeconds then
				statPushAccumulator[player] = 0
				StatsBroadcaster.Push(player, profile)
			end
		end
	end

	saveAccumulator += dt
	if saveAccumulator >= 120 then
		saveAccumulator = 0
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerDataManager.Save(player)
		end
	end
end)
