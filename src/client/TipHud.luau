--!strict
-- The on-screen tip jar: a counter that rolls up and bounces when you earn tips,
-- the team streak with its bonus, and a hint while you're carrying something.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local FX = StoreConfig.Effects
local BOUNCE = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local ROLL = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local TipHud = {}

local function corner(parent: Instance)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = parent
end

local function text(parent: Instance, name: string, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.Parent = parent
	return label
end

local function pill(parent: Instance, name: string, position: UDim2, size: UDim2): (Frame, UIScale)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.Parent = parent
	corner(frame)
	local stroke = Instance.new("UIStroke")
	stroke.Color = C.Trim
	stroke.Thickness = 3
	stroke.Parent = frame
	local scale = Instance.new("UIScale")
	scale.Parent = frame
	return frame, scale
end

local function bounce(scale: UIScale, from: number)
	scale.Scale = from
	TweenService:Create(scale, BOUNCE, { Scale = 1 }):Play()
end

local function buildTipCounter(gui: ScreenGui, tips: IntValue)
	local frame, scale = pill(gui, "Tips", UDim2.new(0.5, 0, 0, 12), UDim2.fromOffset(190, 46))

	local coin = Instance.new("Frame")
	coin.Size = UDim2.fromOffset(32, 32)
	coin.Position = UDim2.fromOffset(8, 7)
	coin.BackgroundColor3 = FX.TipGold
	coin.Parent = frame
	corner(coin)
	local coinMark = text(coin, "Mark", Color3.new(1, 1, 1))
	coinMark.Size = UDim2.fromScale(1, 1)
	coinMark.Text = "T"

	local label = text(frame, "Amount", C.SignText)
	label.Position = UDim2.fromOffset(46, 6)
	label.Size = UDim2.new(1, -56, 1, -12)
	label.TextXAlignment = Enum.TextXAlignment.Left

	-- The shown number rolls toward the real total.
	local shown = Instance.new("NumberValue")
	shown.Value = tips.Value
	local function render()
		label.Text = tostring(math.floor(shown.Value + 0.5)) .. " tips"
	end
	shown.Changed:Connect(render)
	render()

	local last = tips.Value
	tips.Changed:Connect(function(value: number)
		TweenService:Create(shown, ROLL, { Value = value }):Play()
		if value > last then
			bounce(scale, 1.25)
		end
		last = value
	end)
end

local function buildStreak(gui: ScreenGui)
	local frame, scale = pill(gui, "Streak", UDim2.new(0.5, 0, 0, 64), UDim2.fromOffset(230, 34))
	local label = text(frame, "Label", C.Neon)
	label.Position = UDim2.fromOffset(10, 4)
	label.Size = UDim2.new(1, -20, 1, -8)

	local cfg = StoreConfig.Tips
	local last = 0
	local function update()
		local streak = (ReplicatedStorage:GetAttribute("TeamStreak") or 0) :: number
		frame.Visible = streak >= 2
		local bonus = math.min(streak * cfg.StreakStep, cfg.StreakMaxBonus)
		label.Text = ("Streak x%d  +%d%% tips"):format(streak, math.floor(bonus * 100 + 0.5))
		if streak > last and frame.Visible then
			bounce(scale, 1.4)
		end
		last = streak
	end
	ReplicatedStorage:GetAttributeChangedSignal("TeamStreak"):Connect(update)
	update()
end

local function buildHint(gui: ScreenGui, player: Player)
	local frame, scale = pill(gui, "Hint", UDim2.new(0.5, 0, 1, -140), UDim2.fromOffset(300, 36))
	local label = text(frame, "Label", C.SignText)
	label.Position = UDim2.fromOffset(12, 5)
	label.Size = UDim2.new(1, -24, 1, -10)

	local function update()
		local holding = player:GetAttribute("Holding") :: string?
		local item = holding and StoreConfig.Items[holding]
		frame.Visible = item ~= nil
		if item then
			label.Text = "Bring the " .. item.DisplayName .. " to a customer!"
			bounce(scale, 0.6)
		end
	end
	player:GetAttributeChangedSignal("Holding"):Connect(update)
	update()
end

function TipHud.init()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "TipHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local stats = player:WaitForChild("leaderstats")
	buildTipCounter(gui, stats:WaitForChild("Tips") :: IntValue)
	buildStreak(gui)
	buildHint(gui, player)
end

return TipHud
