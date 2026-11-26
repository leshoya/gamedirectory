--!strict
-- A speech bubble over a customer's head, with an optional patience bar that drains
-- from mint to pink while they wait.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local POP = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

export type Bubble = {
	say: (text: string) -> (),
	setPatience: (fraction: number?) -> (),
	hide: () -> (),
}

local SpeechBubble = {}

local function corner(parent: Instance, scale: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale, 0)
	c.Parent = parent
end

function SpeechBubble.create(head: BasePart): Bubble
	local gui = Instance.new("BillboardGui")
	gui.Name = "SpeechBubble"
	gui.Size = UDim2.fromScale(6, 2.2) -- in studs, so it shrinks with distance like a real sign
	gui.StudsOffset = Vector3.new(0, 2.8, 0)
	gui.MaxDistance = StoreConfig.Customers.BubbleMaxDistance
	gui.LightInfluence = 0
	gui.Enabled = false
	gui.Adornee = head
	gui.Parent = head

	local scale = Instance.new("UIScale")
	scale.Parent = gui

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 0.62)
	bubble.BackgroundColor3 = Color3.new(1, 1, 1)
	bubble.Parent = gui
	corner(bubble, 0.35)
	local stroke = Instance.new("UIStroke")
	stroke.Color = C.Trim
	stroke.Thickness = 3
	stroke.Parent = bubble

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Size = UDim2.fromScale(0.9, 0.8)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = C.SignText
	label.Parent = bubble

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.fromScale(0.5, 0.72)
	bar.Size = UDim2.fromScale(0.7, 0.14)
	bar.BackgroundColor3 = Color3.fromRGB(235, 225, 240)
	bar.Visible = false
	bar.Parent = gui
	corner(bar, 0.5)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = StoreConfig.Effects.Good
	fill.Parent = bar
	corner(fill, 0.5)

	local function say(text: string)
		label.Text = text
		gui.Enabled = true
		scale.Scale = 0.3
		TweenService:Create(scale, POP, { Scale = 1 }):Play()
	end

	local function setPatience(fraction: number?)
		if fraction == nil then
			bar.Visible = false
			return
		end
		local f = math.clamp(fraction, 0, 1)
		bar.Visible = true
		fill.Size = UDim2.fromScale(f, 1)
		fill.BackgroundColor3 = StoreConfig.Effects.Bad:Lerp(StoreConfig.Effects.Good, f)
	end

	local function hide()
		gui.Enabled = false
	end

	return { say = say, setPatience = setPatience, hide = hide }
end

return SpeechBubble
