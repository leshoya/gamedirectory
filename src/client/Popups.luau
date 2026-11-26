--!strict
-- Floating world text ("+12 tips", "Speedy!") that pops in, rises and fades away.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local POP = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local Popups = {}

function Popups.show(text: string, position: Vector3, color: Color3)
	local fx = StoreConfig.Effects
	local rise = TweenInfo.new(fx.PopupTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = position
	attachment.Parent = workspace.Terrain

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 50) -- in pixels, so it stays readable at any distance
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = 80
	gui.Adornee = attachment
	gui.Parent = attachment

	local scale = Instance.new("UIScale")
	scale.Scale = 0.2
	scale.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color
	label.Text = text
	label.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 2.5
	stroke.Parent = label

	TweenService:Create(scale, POP, { Scale = 1 }):Play()
	TweenService:Create(gui, rise, { StudsOffset = Vector3.new(0, fx.PopupRise, 0) }):Play()
	local fade = TweenService:Create(label, rise, { TextTransparency = 1 })
	TweenService:Create(stroke, rise, { Transparency = 1 }):Play()
	fade.Completed:Once(function()
		attachment:Destroy()
	end)
	fade:Play()
end

return Popups
