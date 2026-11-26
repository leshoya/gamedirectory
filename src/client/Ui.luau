--!strict
-- Small helpers for the pastel UI: rounded white panels, labels and buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local POP = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local Ui = {}

function Ui.corner(parent: Instance, radius: UDim?)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 14)
	c.Parent = parent
end

function Ui.stroke(parent: Instance, color: Color3?, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Trim
	s.Thickness = thickness or 3
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

function Ui.panel(parent: Instance, name: string, size: UDim2, position: UDim2, anchor: Vector2?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor or Vector2.zero
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.Parent = parent
	Ui.corner(frame)
	Ui.stroke(frame)
	return frame
end

function Ui.label(parent: Instance, text: string, size: UDim2, position: UDim2, color: Color3?, align: Enum.TextXAlignment?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = color or C.SignText
	label.TextXAlignment = align or Enum.TextXAlignment.Center
	label.Text = text
	label.Size = size
	label.Position = position
	label.Parent = parent
	return label
end

function Ui.button(parent: Instance, text: string, size: UDim2, position: UDim2, color: Color3, onClick: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Font = Enum.Font.FredokaOne
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.AutoButtonColor = true
	button.Parent = parent
	Ui.corner(button, UDim.new(0, 10))
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = button
	button.Activated:Connect(onClick)
	return button
end

-- Pops a frame in from small.
function Ui.popIn(frame: GuiObject)
	local scale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	scale.Parent = frame
	scale.Scale = 0.5
	TweenService:Create(scale, POP, { Scale = 1 }):Play()
end

-- Hides this game's HUD screens (not Roblox's own, like proximity prompts) for a cutscene.
-- Returns a function that shows them again.
local HUD = { "ShiftHud", "TipHud", "Menu", "Results" }
function Ui.hideHud(): () -> ()
	local hidden = {}
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	for _, name in HUD do
		local gui = playerGui:FindFirstChild(name)
		if gui and gui:IsA("ScreenGui") and gui.Enabled then
			gui.Enabled = false
			table.insert(hidden, gui)
		end
	end
	return function()
		for _, gui in hidden do
			gui.Enabled = true
		end
	end
end

function Ui.screen(name: string, order: number?): ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.DisplayOrder = order or 0
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	return gui
end

return Ui
