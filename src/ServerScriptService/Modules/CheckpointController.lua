-- Progression up the mountain comes from physically walking into checkpoint
-- parts placed along the ridge in Workspace.Checkpoints (one per Camps.lua
-- entry, named to match its `id`), not from a UI button. The mesh is scaled
-- ~550x the height of a default Roblox character (see
-- assets/models/matterhorn/README.md), so the walk itself -- at a WalkSpeed
-- that gets deliberately slower on technical ground -- is what gives the
-- climb real duration, instead of an artificial timer.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camps = require(ReplicatedStorage.Modules.Camps)
local Constants = require(ReplicatedStorage.Modules.Constants)

local PlayerDataManager = require(script.Parent.PlayerDataManager)
local CampController = require(script.Parent.CampController)
local StatsBroadcaster = require(script.Parent.StatsBroadcaster)

local Remotes = ReplicatedStorage.Remotes

local CheckpointController = {}

local CampIndexById = {}
for i, camp in ipairs(Camps) do
	CampIndexById[camp.id] = i
end

local function applyWalkSpeedForCampIndex(player, campIndex)
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local camp = Camps[campIndex]
	local speed = Constants.BaseWalkSpeed * (1 - Constants.WalkSpeedDifficultyFactor * camp.technicalDifficulty)
	humanoid.WalkSpeed = math.max(Constants.MinWalkSpeed, speed)
end

local function handleCrossing(player, campIndex)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return
	end

	if profile.ascending and campIndex == profile.campIndex + 1 then
		local ok, result = CampController.Advance(player)
		if ok then
			StatsBroadcaster.Push(player, profile)
			applyWalkSpeedForCampIndex(player, profile.campIndex)
			Remotes.CampReached:FireClient(player, {
				camp = result.camp,
				ascending = profile.ascending,
				elapsedSeconds = result.elapsedSeconds,
				targetSeconds = result.targetSeconds,
			})
		else
			Remotes.GameLog:FireClient(player, tostring(result))
		end
	elseif campIndex == profile.campIndex - 1 then
		local ok, result = CampController.Retreat(player)
		if ok then
			StatsBroadcaster.Push(player, profile)
			applyWalkSpeedForCampIndex(player, profile.campIndex)
			Remotes.CampReached:FireClient(player, { camp = result, ascending = profile.ascending })
		end
	end
	-- Any other campIndex (further away than one step) is ignored: the
	-- ridge only goes in sequence, no skipping ahead by flying/clipping
	-- past intermediate checkpoints.
end

function CheckpointController.Setup()
	local checkpointsFolder = Workspace:WaitForChild("Checkpoints")

	local function wireUp(part)
		local campIndex = CampIndexById[part.Name]
		if not campIndex then
			warn("CheckpointController: Workspace.Checkpoints has a part named '" .. part.Name .. "' that doesn't match any Camps.lua id")
			return
		end
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = character and Players:GetPlayerFromCharacter(character)
			if player then
				handleCrossing(player, campIndex)
			end
		end)
	end

	for _, part in ipairs(checkpointsFolder:GetChildren()) do
		if part:IsA("BasePart") then
			wireUp(part)
		end
	end
	checkpointsFolder.ChildAdded:Connect(function(child)
		if child:IsA("BasePart") then
			wireUp(child)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			local profile = PlayerDataManager.Get(player)
			applyWalkSpeedForCampIndex(player, profile and profile.campIndex or 1)
		end)
	end)
end

return CheckpointController
