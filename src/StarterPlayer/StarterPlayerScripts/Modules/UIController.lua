local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local GearConfig = game:GetService("ReplicatedStorage").Modules.GearConfig
GearConfig = require(GearConfig)

local player = Players.LocalPlayer

local UIController = {}
UIController._callbacks = {} -- button id -> function

local function makeBar(parent, color, order)
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 0, 16)
	track.LayoutOrder = order
	track.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	track.BorderSizePixel = 0
	track.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = ""
	label.Parent = track

	return track, fill, label
end

local function makeButton(parent, text, order)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 36)
	button.LayoutOrder = order
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.Parent = parent
	return button
end

function UIController.Init()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClimbHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Top panel: where you are, altitude, weather
	local topPanel = Instance.new("Frame")
	topPanel.Name = "TopPanel"
	topPanel.Size = UDim2.new(0, 320, 0, 90)
	topPanel.Position = UDim2.new(0, 16, 0, 16)
	topPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	topPanel.BackgroundTransparency = 0.15
	topPanel.Parent = screenGui
	Instance.new("UICorner", topPanel).CornerRadius = UDim.new(0, 8)

	local topLayout = Instance.new("UIListLayout")
	topLayout.Padding = UDim.new(0, 2)
	topLayout.Parent = topPanel
	local topPad = Instance.new("UIPadding")
	topPad.PaddingLeft = UDim.new(0, 12)
	topPad.PaddingTop = UDim.new(0, 8)
	topPad.PaddingRight = UDim.new(0, 12)
	topPad.Parent = topPanel

	local campLabel = Instance.new("TextLabel")
	campLabel.Size = UDim2.new(1, 0, 0, 22)
	campLabel.BackgroundTransparency = 1
	campLabel.Font = Enum.Font.GothamBold
	campLabel.TextSize = 18
	campLabel.TextXAlignment = Enum.TextXAlignment.Left
	campLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	campLabel.Text = "Zermatt"
	campLabel.Parent = topPanel

	local altLabel = Instance.new("TextLabel")
	altLabel.Size = UDim2.new(1, 0, 0, 16)
	altLabel.BackgroundTransparency = 1
	altLabel.Font = Enum.Font.Gotham
	altLabel.TextSize = 13
	altLabel.TextXAlignment = Enum.TextXAlignment.Left
	altLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
	altLabel.Text = "1620 m"
	altLabel.Parent = topPanel

	local weatherLabel = Instance.new("TextLabel")
	weatherLabel.Size = UDim2.new(1, 0, 0, 16)
	weatherLabel.BackgroundTransparency = 1
	weatherLabel.Font = Enum.Font.Gotham
	weatherLabel.TextSize = 13
	weatherLabel.TextXAlignment = Enum.TextXAlignment.Left
	weatherLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	weatherLabel.Text = "Clear"
	weatherLabel.Parent = topPanel

	local directionLabel = Instance.new("TextLabel")
	directionLabel.Size = UDim2.new(1, 0, 0, 16)
	directionLabel.BackgroundTransparency = 1
	directionLabel.Font = Enum.Font.Gotham
	directionLabel.TextSize = 13
	directionLabel.TextXAlignment = Enum.TextXAlignment.Left
	directionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	directionLabel.Text = ""
	directionLabel.Parent = topPanel

	-- Stat bars
	local statsPanel = Instance.new("Frame")
	statsPanel.Name = "StatsPanel"
	statsPanel.Size = UDim2.new(0, 320, 0, 110)
	statsPanel.Position = UDim2.new(0, 16, 0, 114)
	statsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	statsPanel.BackgroundTransparency = 0.15
	statsPanel.Parent = screenGui
	Instance.new("UICorner", statsPanel).CornerRadius = UDim.new(0, 8)

	local statsLayout = Instance.new("UIListLayout")
	statsLayout.Padding = UDim.new(0, 6)
	statsLayout.Parent = statsPanel
	local statsPad = Instance.new("UIPadding")
	statsPad.PaddingLeft = UDim.new(0, 12)
	statsPad.PaddingTop = UDim.new(0, 10)
	statsPad.PaddingRight = UDim.new(0, 12)
	statsPad.Parent = statsPanel

	local _, healthFill, healthLabel = makeBar(statsPanel, Color3.fromRGB(210, 60, 60), 1)
	local _, staminaFill, staminaLabel = makeBar(statsPanel, Color3.fromRGB(90, 170, 90), 2)
	local _, focusFill, focusLabel = makeBar(statsPanel, Color3.fromRGB(90, 140, 210), 3)

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Size = UDim2.new(1, 0, 0, 18)
	moneyLabel.LayoutOrder = 4
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextSize = 13
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
	moneyLabel.TextColor3 = Color3.fromRGB(230, 200, 100)
	moneyLabel.Text = "CHF 0"
	moneyLabel.Parent = statsPanel

	-- Action buttons
	local actionsPanel = Instance.new("Frame")
	actionsPanel.Name = "ActionsPanel"
	actionsPanel.Size = UDim2.new(0, 200, 0, 230)
	actionsPanel.Position = UDim2.new(1, -216, 1, -246)
	actionsPanel.AnchorPoint = Vector2.new(0, 0)
	actionsPanel.BackgroundTransparency = 1
	actionsPanel.Parent = screenGui

	local actionsLayout = Instance.new("UIListLayout")
	actionsLayout.Padding = UDim.new(0, 8)
	actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	actionsLayout.Parent = actionsPanel

	local advanceButton = makeButton(actionsPanel, "Advance", 1)
	local retreatButton = makeButton(actionsPanel, "Retreat", 2)
	local restButton = makeButton(actionsPanel, "Rest", 3)
	local shopButton = makeButton(actionsPanel, "Gear Shop", 4)

	advanceButton.MouseButton1Click:Connect(function()
		if UIController._callbacks.Advance then
			UIController._callbacks.Advance()
		end
	end)
	retreatButton.MouseButton1Click:Connect(function()
		if UIController._callbacks.Retreat then
			UIController._callbacks.Retreat()
		end
	end)
	restButton.MouseButton1Click:Connect(function()
		if UIController._callbacks.Rest then
			UIController._callbacks.Rest()
		end
	end)

	-- Gear shop panel (hidden by default)
	local shopPanel = Instance.new("Frame")
	shopPanel.Name = "ShopPanel"
	shopPanel.Size = UDim2.new(0, 260, 0, 320)
	shopPanel.Position = UDim2.new(0.5, -130, 0.5, -160)
	shopPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	shopPanel.BackgroundTransparency = 0.05
	shopPanel.Visible = false
	shopPanel.Parent = screenGui
	Instance.new("UICorner", shopPanel).CornerRadius = UDim.new(0, 10)

	local shopTitle = Instance.new("TextLabel")
	shopTitle.Size = UDim2.new(1, 0, 0, 30)
	shopTitle.BackgroundTransparency = 1
	shopTitle.Font = Enum.Font.GothamBold
	shopTitle.TextSize = 16
	shopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	shopTitle.Text = "Gear Shop"
	shopTitle.Parent = shopPanel

	local closeShopButton = Instance.new("TextButton")
	closeShopButton.Size = UDim2.new(0, 24, 0, 24)
	closeShopButton.Position = UDim2.new(1, -30, 0, 4)
	closeShopButton.BackgroundTransparency = 1
	closeShopButton.Text = "X"
	closeShopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeShopButton.Font = Enum.Font.GothamBold
	closeShopButton.Parent = shopPanel
	closeShopButton.MouseButton1Click:Connect(function()
		shopPanel.Visible = false
	end)

	local shopList = Instance.new("ScrollingFrame")
	shopList.Size = UDim2.new(1, -16, 1, -40)
	shopList.Position = UDim2.new(0, 8, 0, 34)
	shopList.BackgroundTransparency = 1
	shopList.ScrollBarThickness = 4
	shopList.CanvasSize = UDim2.new(0, 0, 0, 0)
	shopList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	shopList.Parent = shopPanel

	local shopLayout = Instance.new("UIListLayout")
	shopLayout.Padding = UDim.new(0, 6)
	shopLayout.Parent = shopList

	for _, gear in ipairs(GearConfig) do
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
		row.Text = string.format("%s -- CHF %d", gear.name, gear.cost)
		row.Font = Enum.Font.Gotham
		row.TextSize = 13
		row.TextColor3 = Color3.fromRGB(255, 255, 255)
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
		row.Parent = shopList
		row.MouseButton1Click:Connect(function()
			if UIController._callbacks.BuyGear then
				UIController._callbacks.BuyGear(gear.id)
			end
		end)
	end

	shopButton.MouseButton1Click:Connect(function()
		shopPanel.Visible = not shopPanel.Visible
	end)

	-- Log feed (bottom-left), transient messages
	local logPanel = Instance.new("Frame")
	logPanel.Name = "LogPanel"
	logPanel.Size = UDim2.new(0, 420, 0, 150)
	logPanel.Position = UDim2.new(0, 16, 1, -166)
	logPanel.BackgroundTransparency = 1
	logPanel.Parent = screenGui

	local logLayout = Instance.new("UIListLayout")
	logLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	logLayout.Padding = UDim.new(0, 4)
	logLayout.Parent = logPanel

	UIController._elements = {
		campLabel = campLabel,
		altLabel = altLabel,
		weatherLabel = weatherLabel,
		directionLabel = directionLabel,
		healthFill = healthFill,
		healthLabel = healthLabel,
		staminaFill = staminaFill,
		staminaLabel = staminaLabel,
		focusFill = focusFill,
		focusLabel = focusLabel,
		moneyLabel = moneyLabel,
		logPanel = logPanel,
	}
end

function UIController.OnAction(name, callback)
	UIController._callbacks[name] = callback
end

local function setBar(fill, label, value, max, text)
	local pct = math.clamp(value / max, 0, 1)
	fill.Size = UDim2.new(pct, 0, 1, 0)
	label.Text = text
end

function UIController.UpdateStats(data)
	local e = UIController._elements
	if not e then
		return
	end

	e.campLabel.Text = data.campName or ""
	e.altLabel.Text = string.format("%d m", data.altitude or 0)
	e.weatherLabel.Text = data.weatherState or "Clear"
	e.directionLabel.Text = data.ascending and "Ascending" or "Descending"

	setBar(e.healthFill, e.healthLabel, data.health or 0, 100, string.format("Health  %d", math.floor(data.health or 0)))
	setBar(e.staminaFill, e.staminaLabel, data.stamina or 0, 100, string.format("Stamina  %d", math.floor(data.stamina or 0)))
	setBar(e.focusFill, e.focusLabel, data.focus or 0, 100, string.format("Focus  %d", math.floor(data.focus or 0)))
	e.moneyLabel.Text = string.format("CHF %d", data.money or 0)
end

function UIController.PushLog(message, color)
	local e = UIController._elements
	if not e then
		return
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.5
	label.Text = message
	label.Parent = e.logPanel

	task.delay(6, function()
		local tween = TweenService:Create(label, TweenInfo.new(1), { TextTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		label:Destroy()
	end)
end

return UIController
