--!strict
-- A full-screen jumpscare: the plush's face lunges at the camera with a shake, a red vignette
-- and a loud hit. "Small" is a quick jolt (serving an anomaly); "Big" is getting caught.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local Jumpscare = {}

local busy = false

local function vignette(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(150, 0, 10)
	frame.BackgroundTransparency = 0.2
	frame.ZIndex = 2
	frame.Parent = parent
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.3, 1),
		NumberSequenceKeypoint.new(0.7, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Parent = frame
	return frame
end

function Jumpscare.play(model: Model?, size: "Small" | "Big")
	if busy or not model or not model.Parent then
		return
	end
	busy = true
	local cfg = StoreConfig.Jumpscare
	local duration = if size == "Big" then cfg.BigTime else cfg.SmallTime

	local gui = Instance.new("ScreenGui")
	gui.Name = "Jumpscare"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.ResetOnSpawn = false

	local view = Instance.new("ViewportFrame")
	view.Size = UDim2.fromScale(1.1, 1.1)
	view.AnchorPoint = Vector2.new(0.5, 0.5)
	view.Position = UDim2.fromScale(0.5, 0.5)
	view.BackgroundColor3 = Color3.new(0, 0, 0)
	view.BackgroundTransparency = if size == "Big" then 0 else 0.35
	view.Ambient = Color3.fromRGB(120, 60, 60)
	view.LightColor = Color3.fromRGB(255, 200, 190)
	view.LightDirection = Vector3.new(0, -1, 0.3)
	view.Parent = gui

	model.Archivable = true
	local copy = model:Clone()
	copy.Parent = view
	local head = copy:FindFirstChild("Head", true) :: BasePart?
	local pivot = copy:GetPivot()
	local face = if head then head.Position else pivot.Position + Vector3.new(0, 2, 0)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 50
	camera.Parent = view
	view.CurrentCamera = camera

	-- Start a little back and rush in until the face fills the screen.
	local forward = pivot.LookVector
	local value = Instance.new("NumberValue")
	value.Value = 9
	local function aim()
		camera.CFrame = CFrame.lookAt(face + forward * value.Value, face)
	end
	aim()
	vignette(gui)
	gui.Parent = (Players.LocalPlayer :: Player):WaitForChild("PlayerGui")

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. cfg.Sound.Id
	sound.Volume = cfg.Sound.Volume * (if size == "Big" then 1 else 0.6)
	sound.PlaybackSpeed = if size == "Big" then 0.9 else 1.15
	sound.Parent = SoundService
	sound:Play()

	TweenService:Create(value, TweenInfo.new(duration * 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Value = 2.2 }):Play()
	local strength = if size == "Big" then 0.03 else 0.015
	local started = os.clock()
	local connection = RunService.RenderStepped:Connect(function()
		aim()
		local fade = 1 - (os.clock() - started) / duration
		view.Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * strength * fade, 0.5 + (math.random() - 0.5) * strength * fade)
	end)

	task.wait(duration)
	connection:Disconnect()
	gui:Destroy()
	value:Destroy()
	task.delay(3, function()
		sound:Destroy()
	end)
	busy = false
end

return Jumpscare
