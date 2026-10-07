local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local UIController = require(script.Parent.Modules.UIController)

UIController.Init()

local eventColors = {
	Rockfall = Color3.fromRGB(230, 170, 80),
	Slip = Color3.fromRGB(230, 170, 80),
	Lightning = Color3.fromRGB(255, 90, 90),
	Fatigue = Color3.fromRGB(200, 200, 120),
}

Remotes.UpdateStats.OnClientEvent:Connect(function(data)
	UIController.UpdateStats(data)
	if data.alive == false then
		UIController.PushLog("You didn't make it. Respawning in Zermatt...", Color3.fromRGB(255, 90, 90))
	end
end)

Remotes.WeatherChanged.OnClientEvent:Connect(function(state)
	local messages = {
		Clouding = "Clouds are building over the ridge.",
		Windy = "Wind is picking up -- footing is getting harder.",
		Thunderstorm = "Thunderstorm. This is exactly what the alpine start was supposed to avoid.",
		Clear = "Skies are clear.",
	}
	UIController.PushLog(messages[state] or state, Color3.fromRGB(150, 200, 255))
end)

Remotes.RiskEvent.OnClientEvent:Connect(function(event)
	UIController.PushLog(string.format("%s (-%d)", event.message, math.floor(event.damage)), eventColors[event.type])
end)

Remotes.CampReached.OnClientEvent:Connect(function(data)
	local camp = data.camp
	if camp then
		UIController.PushLog(string.format("Reached %s (%d m).", camp.name, camp.altitude), Color3.fromRGB(255, 255, 255))
	end
end)

Remotes.GameLog.OnClientEvent:Connect(function(message)
	UIController.PushLog(message, Color3.fromRGB(200, 200, 200))
end)

UIController.OnAction("Rest", function()
	local ok, result = Remotes.RestAtCamp:InvokeServer()
	if ok then
		UIController.PushLog("Resting... stamina and focus recovering.", Color3.fromRGB(150, 230, 150))
	else
		UIController.PushLog(tostring(result), Color3.fromRGB(255, 150, 150))
	end
end)

UIController.OnAction("BuyGear", function(gearId)
	local ok, result = Remotes.BuyGear:InvokeServer(gearId)
	if ok then
		UIController.PushLog(string.format("Bought %s for CHF %d.", gearId, result.cost), Color3.fromRGB(230, 200, 100))
	else
		UIController.PushLog(tostring(result), Color3.fromRGB(255, 150, 150))
	end
end)
