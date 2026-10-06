local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camps = require(ReplicatedStorage.Modules.Camps)
local GearConfig = require(ReplicatedStorage.Modules.GearConfig)
local Constants = require(ReplicatedStorage.Modules.Constants)
local RouteRules = require(ReplicatedStorage.Modules.RouteRules)

local PlayerDataManager = require(script.Parent.PlayerDataManager)
local WeatherController = require(script.Parent.WeatherController)

local RiskEventController = {}

local GearById = {}
for _, gear in ipairs(GearConfig) do
	GearById[gear.id] = gear
end

local HornliHutIndex
for i, camp in ipairs(Camps) do
	if camp.id == "HornliHut" then
		HornliHutIndex = i
		break
	end
end

local function gearFactor(profile, gearId, field)
	local gear = GearById[gearId]
	if gear and profile.gear[gearId] then
		return gear[field] or 0
	end
	return 0
end

local function rollDamage(range)
	return math.random(range.min, range.max)
end

-- Applies gear mitigation that reduces fall-type damage (Harness, Rope).
local function mitigateFallDamage(profile, damage)
	local reduction = gearFactor(profile, "Harness", "reducesFallDamage")
		+ gearFactor(profile, "Rope", "reducesFallDamage")
	reduction = math.min(reduction, 0.9)
	return damage * (1 - reduction)
end

local function applyDamage(profile, amount)
	profile.health -= amount
	if profile.health <= 0 then
		profile.health = 0
		profile.alive = false
	end
end

-- Returns a list of {type, message, damage} events that fired this check.
function RiskEventController.Check(player)
	local profile = PlayerDataManager.Get(player)
	if not profile or not profile.alive then
		return {}
	end

	local camp = Camps[profile.campIndex]
	local weatherConf = WeatherController.GetStateConfig(profile)
	local isDescending = not profile.ascending

	local overdue = profile.ascending and RouteRules.IsOverdueAtSolvay(profile, profile.hutDepartureClock)
	local overallMultiplier = overdue and RouteRules.OverdueRiskMultiplier or 1

	local events = {}
	local cfg = Constants.RiskEvents

	-- Rockfall: scaled by how loose this stretch of ridge is and by weather.
	-- Afternoon sun loosens rock that was frozen at the alpine start, so
	-- descending the same ground is worse than climbing it was.
	local rockfallChance = cfg.Rockfall.baseChance * camp.rockfallRisk * weatherConf.rockfallRiskMultiplier * overallMultiplier
	if isDescending then
		rockfallChance *= RouteRules.DescentRockfallMultiplier
	end
	if math.random() < rockfallChance then
		local damage = rollDamage(cfg.Rockfall.damage) * (1 - gearFactor(profile, "Helmet", "reducesRockfallDamage"))
		applyDamage(profile, damage)
		table.insert(events, { type = "Rockfall", message = cfg.Rockfall.message, damage = damage })
	end

	-- Slip: the technical climbing itself (Moseley Slab, the fixed ropes).
	-- Crampons/Ice Axe reduce the chance of it happening; Harness/Rope
	-- reduce how bad it is when it does.
	local slipChance = cfg.Slip.baseChance * camp.technicalDifficulty * overallMultiplier
	slipChance *= (1 - gearFactor(profile, "Crampons", "reducesSlipChance"))
	slipChance *= (1 - gearFactor(profile, "IceAxe", "reducesSlipChance"))
	if math.random() < slipChance then
		local damage = mitigateFallDamage(profile, rollDamage(cfg.Slip.damage))
		applyDamage(profile, damage)
		table.insert(events, { type = "Slip", message = cfg.Slip.message, damage = damage })
	end

	-- Lightning: only a risk once you're up on the exposed ridge above the
	-- hut, and only during a thunderstorm.
	if weatherConf.lightningRisk and profile.campIndex >= HornliHutIndex then
		local lightningChance = cfg.Lightning.baseChance * overallMultiplier
		if math.random() < lightningChance then
			local damage = rollDamage(cfg.Lightning.damage)
			applyDamage(profile, damage)
			table.insert(events, { type = "Lightning", message = cfg.Lightning.message, damage = damage })
		end
	end

	-- Fatigue: more likely the lower your stamina, and worse on the
	-- descent -- this is the real mechanism behind "most accidents happen
	-- on the way down."
	local fatigueChance = cfg.Fatigue.baseChance * (1 - profile.stamina / Constants.MaxStamina) * overallMultiplier
	if isDescending then
		fatigueChance *= RouteRules.DescentFatigueChanceMultiplier
	end
	if math.random() < fatigueChance then
		local damage = rollDamage(cfg.Fatigue.damage)
		applyDamage(profile, damage)
		table.insert(events, { type = "Fatigue", message = cfg.Fatigue.message, damage = damage })
	end

	PlayerDataManager.Clamp(profile)
	return events, overdue
end

return RiskEventController
