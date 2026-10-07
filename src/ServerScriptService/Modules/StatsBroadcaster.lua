local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camps = require(ReplicatedStorage.Modules.Camps)

local StatsBroadcaster = {}

function StatsBroadcaster.Push(player, profile)
	local camp = Camps[profile.campIndex]
	ReplicatedStorage.Remotes.UpdateStats:FireClient(player, {
		stamina = profile.stamina,
		health = profile.health,
		focus = profile.focus,
		money = profile.money,
		campIndex = profile.campIndex,
		campName = camp.name,
		altitude = camp.altitude,
		ascending = profile.ascending,
		alive = profile.alive,
		weatherState = profile.weatherState,
		stormClock = profile.stormClock,
		gear = profile.gear,
	})
end

return StatsBroadcaster
