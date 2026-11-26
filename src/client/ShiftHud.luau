--!strict
-- The shift card (night, phase, time left, Dread meter), the power-cut banner and a controls hint.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)

local C = StoreConfig.Colors
local FX = StoreConfig.Effects

local PHASE_TEXT = {
	Waiting = "Your shift starts soon",
	Open = "Opening up...",
	Service = "Open for customers",
	Close = "Closing up",
	Blackout = "BLACKOUT - reset the breaker!",
	Won = "Sunrise!",
	Lost = "The store is dark...",
}

local ShiftHud = {}

local function formatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return ("%d:%02d"):format(seconds // 60, seconds % 60)
end

function ShiftHud.init()
	local gui = Ui.screen("ShiftHud")

	local card = Ui.panel(gui, "Shift", UDim2.fromOffset(230, 104), UDim2.fromOffset(12, 12))
	local title = Ui.label(card, "", UDim2.new(1, -24, 0, 30), UDim2.fromOffset(12, 8), C.SignText, Enum.TextXAlignment.Left)
	local timer = Ui.label(card, "", UDim2.new(0, 70, 0, 30), UDim2.new(1, -82, 0, 8), C.Neon, Enum.TextXAlignment.Right)
	local phase = Ui.label(card, "", UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 40), C.Trim:Lerp(C.SignText, 0.5), Enum.TextXAlignment.Left)

	Ui.label(card, "Dread", UDim2.fromOffset(60, 18), UDim2.fromOffset(12, 72), C.SignText, Enum.TextXAlignment.Left)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -90, 0, 14)
	bar.Position = UDim2.fromOffset(76, 74)
	bar.BackgroundColor3 = Color3.fromRGB(240, 232, 245)
	bar.Parent = card
	Ui.corner(bar, UDim.new(0.5, 0))
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = FX.Good
	fill.Parent = bar
	Ui.corner(fill, UDim.new(0.5, 0))

	local banner = Ui.panel(gui, "PowerOut", UDim2.fromOffset(340, 40), UDim2.new(0.5, 0, 0, 112), Vector2.new(0.5, 0))
	banner.BackgroundColor3 = Color3.fromRGB(60, 30, 60)
	local bannerText = Ui.label(banner, "Power out! Hold E at the breaker", UDim2.new(1, -20, 1, -10), UDim2.fromOffset(10, 5), Color3.new(1, 1, 1))
	banner.Visible = false

	local hint = Ui.label(gui, "E  serve / make      F  turn away", UDim2.fromOffset(280, 22), UDim2.new(1, -292, 1, -34), Color3.new(1, 1, 1), Enum.TextXAlignment.Right)
	local hintStroke = Instance.new("UIStroke")
	hintStroke.Color = C.SignText
	hintStroke.Thickness = 1.5
	hintStroke.Parent = hint

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local night = (ReplicatedStorage:GetAttribute("Night") or 0) :: number
		local phaseName = (ReplicatedStorage:GetAttribute("Phase") or "Waiting") :: string
		local endsAt = ReplicatedStorage:GetAttribute("PhaseEndsAt") :: number?
		local dread = ((ReplicatedStorage:GetAttribute("Dread") or 0) :: number) / StoreConfig.Dread.Max

		title.Text = if night > 0 then ("Night %d of %d"):format(night, #StoreConfig.Nights) else "Night Shift"
		phase.Text = PHASE_TEXT[phaseName] or phaseName
		timer.Text = if endsAt then formatTime(endsAt - workspace:GetServerTimeNow()) else ""

		fill.Size = UDim2.fromScale(math.clamp(dread, 0, 1), 1)
		fill.BackgroundColor3 = if dread < 0.5
			then FX.Good:Lerp(C.Neon, dread * 2)
			else C.Neon:Lerp(Color3.fromRGB(90, 70, 100), (dread - 0.5) * 2)

		local out = ReplicatedStorage:GetAttribute("PowerOut") == true
		banner.Visible = out
		if out then
			bannerText.Text = if phaseName == "Blackout" then "BLACKOUT! Reset the breaker!" else "Power out! Hold E at the breaker"
			banner.BackgroundTransparency = 0.15 + 0.15 * math.sin(elapsed * 6)
		end
	end)
end

return ShiftHud
