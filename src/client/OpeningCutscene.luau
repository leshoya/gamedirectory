--!strict
-- The opening: it's 11:47 PM, you're broke, and you're walking home down a dark street,
-- thinking out loud. Then a glowing little store, a HELP WANTED sign in the window, a decision,
-- a neon title card, and you walk in the door. Letterboxed, with a Skip button.
-- Plays once for new workers, right before Manager Mochi's welcome (client/Intro.luau).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)
local Sounds = require(script.Parent.Sounds)
local Controls = require(script.Parent.Controls)

local S = StoreConfig.Size
local C = StoreConfig.Colors

local OpeningCutscene = {}

local STREET_Z = S.Depth / 2 + S.WallThickness + 7 -- the middle of the sidewalk
local WALK_SPEED = 4 -- a slow, tired trudge that lasts through the thoughts

local setControls = Controls.setEnabled

local function tween(object: Instance, seconds: number, goal: { [string]: any }, style: Enum.EasingStyle?)
	local t = TweenService:Create(object, TweenInfo.new(seconds, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), goal)
	t:Play()
	return t
end

function OpeningCutscene.play()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local root = character:WaitForChild("HumanoidRootPart") :: BasePart
	local camera = workspace.CurrentCamera
	local floorY = root.Position.Y

	-- Screen: hide the HUD, add letterbox bars, a black fader, the thought caption and Skip.
	local gui = Ui.screen("Opening", 20)
	gui.IgnoreGuiInset = true
	local showHud = Ui.hideHud()
	local function blackFrame(size: UDim2, position: UDim2, anchor: Vector2): Frame
		local f = Instance.new("Frame")
		f.Size = size
		f.Position = position
		f.AnchorPoint = anchor
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BorderSizePixel = 0
		f.Parent = gui
		return f
	end
	local fader = blackFrame(UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Vector2.zero)
	fader.ZIndex = 5
	local topBar = blackFrame(UDim2.fromScale(1, 0.12), UDim2.fromScale(0, 0), Vector2.zero)
	local bottomBar = blackFrame(UDim2.fromScale(1, 0.12), UDim2.fromScale(0, 1), Vector2.new(0, 1))

	local caption = Ui.label(gui, "", UDim2.new(0.7, 0, 0.07, 0), UDim2.fromScale(0.15, 0.9), Color3.new(1, 1, 1))
	caption.AnchorPoint = Vector2.new(0, 0.5)
	caption.Font = Enum.Font.GothamMedium
	caption.ZIndex = 6
	local clock = Ui.label(gui, "", UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.25, 0.42), Color3.new(1, 1, 1))
	clock.ZIndex = 6

	local skipped = false
	local skip = Ui.button(gui, "Skip  >>", UDim2.fromOffset(120, 40), UDim2.new(1, -140, 0, 20), Color3.fromRGB(60, 50, 80), function()
		skipped = true
	end)
	skip.ZIndex = 7

	local function say(text: string, seconds: number)
		if skipped then
			return
		end
		caption.Text = text
		caption.MaxVisibleGraphemes = 0
		for i = 1, #text do
			if skipped then
				break
			end
			caption.MaxVisibleGraphemes = i
			task.wait(0.03)
		end
		caption.MaxVisibleGraphemes = -1
		local deadline = os.clock() + seconds
		while os.clock() < deadline and not skipped do
			task.wait(0.05)
		end
	end

	local function wait(seconds: number)
		local deadline = os.clock() + seconds
		while os.clock() < deadline and not skipped do
			task.wait(0.05)
		end
	end

	-- The camera follows a function of time until told to stop.
	local cameraJob: (() -> CFrame)? = nil
	local follow = RunService.RenderStepped:Connect(function(dt)
		if cameraJob then
			local goal = cameraJob()
			camera.CFrame = camera.CFrame:Lerp(goal, math.min(1, dt * 3))
		end
	end)

	setControls(false)
	camera.CameraType = Enum.CameraType.Scriptable
	local oldSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = WALK_SPEED

	-- 1. Black screen, the time.
	clock.Text = "11:47 PM"
	clock.TextTransparency = 1
	tween(clock, 1, { TextTransparency = 0 })
	wait(2)
	tween(clock, 0.8, { TextTransparency = 1 })

	-- 2. Walking down the street, thinking.
	local start = Vector3.new(-S.Width / 2 - 10, floorY, STREET_Z)
	root.CFrame = CFrame.lookAt(start, start + Vector3.xAxis)
	local function sideShot(): CFrame
		local p = root.Position
		return CFrame.lookAt(p + Vector3.new(-3, 2.5, 13), p + Vector3.new(3, 1, 0))
	end
	camera.CFrame = sideShot()
	cameraJob = sideShot
	humanoid:MoveTo(Vector3.new(-9, floorY, STREET_Z))
	tween(fader, 1.5, { BackgroundTransparency = 1 })
	wait(1)
	say("Rent's due Friday... and all I've got is three buttons and a gum wrapper.", 2.2)
	say("Fourteen job applications. Zero callbacks.", 2)
	say("Maybe I should just go home and sleep for a year—", 1.2)

	-- 3. The store catches your eye.
	humanoid:MoveTo(Vector3.new(-3, floorY, STREET_Z))
	local storeFront = Vector3.new(0, floorY + 6, S.Depth / 2)
	cameraJob = function()
		return CFrame.lookAt(Vector3.new(4, floorY + 1.5, STREET_Z + 16), storeFront + Vector3.new(0, 2, 0))
	end
	say("...huh?", 1.2)
	Sounds.play("DoorChime")
	say("A store? Open this late?", 1.8)

	-- 4. The sign in the window.
	local sign = workspace:FindFirstChild("Store") and workspace.Store:FindFirstChild("HelpWanted", true) :: BasePart?
	if sign then
		local signAt = sign.Position
		cameraJob = function()
			return CFrame.lookAt(signAt + Vector3.new(1.5, 0.5, 5), signAt)
		end
		root.CFrame = CFrame.lookAt(root.Position, Vector3.new(signAt.X, floorY, signAt.Z))
	end
	say("\"HELP WANTED. Night shift. Must love plushies. Paid in cash!\"", 2.4)
	cameraJob = function()
		local p = root.Position
		return CFrame.lookAt(p + Vector3.new(2, 1.8, 5.5), p + Vector3.new(0, 1.5, 0))
	end
	say("...Cash?", 1)
	say("Okay. How bad could it be?", 1.6)

	-- 5. Title card.
	if not skipped then
		cameraJob = function()
			return CFrame.lookAt(Vector3.new(0, floorY + 2, STREET_Z + 18), storeFront + Vector3.new(0, 3, 0))
		end
		caption.Text = ""
		local title = Ui.label(gui, "MIDNIGHT PLUSHIE MART", UDim2.fromScale(0.8, 0.14), UDim2.fromScale(0.1, 0.3), C.Neon)
		title.ZIndex = 6
		local glow = Instance.new("UIStroke")
		glow.Color = Color3.fromRGB(255, 210, 240)
		glow.Thickness = 3
		glow.Parent = title
		local subtitle = Ui.label(gui, "N I G H T   S H I F T", UDim2.fromScale(0.5, 0.05), UDim2.fromScale(0.25, 0.45), Color3.new(1, 1, 1))
		subtitle.ZIndex = 6
		subtitle.TextTransparency = 1
		Sounds.play("Sparkle")
		-- Neon flicker on
		for _, t in { 1, 0.2, 1, 0, 0.6, 0 } do
			title.TextTransparency = t
			glow.Transparency = t
			task.wait(0.09)
		end
		tween(subtitle, 0.8, { TextTransparency = 0 })
		humanoid.WalkSpeed = 9 -- decided: a quicker step toward the door
		humanoid:MoveTo(Vector3.new(0, floorY, S.Depth / 2 - 2))
		wait(2.6)
		tween(title, 0.6, { TextTransparency = 1 })
		tween(glow, 0.6, { Transparency = 1 })
		tween(subtitle, 0.6, { TextTransparency = 1 })
	end

	-- 6. Walk in, fade out.
	cameraJob = function()
		local p = root.Position
		return CFrame.lookAt(p + Vector3.new(0, 4, 9), p + Vector3.new(0, 2, -4))
	end
	humanoid:MoveTo(StoreConfig.SpawnPosition + Vector3.new(0, floorY, 0))
	wait(1.5)
	tween(fader, 0.6, { BackgroundTransparency = 0 }).Completed:Wait()

	-- Clean up: the worker is inside, by the door.
	follow:Disconnect()
	local inside = StoreConfig.SpawnPosition + Vector3.new(0, floorY, 0)
	root.CFrame = CFrame.lookAt(inside, inside - Vector3.zAxis)
	humanoid:MoveTo(inside)
	humanoid.WalkSpeed = oldSpeed
	caption.Text = ""
	tween(topBar, 0.5, { Size = UDim2.fromScale(1, 0) })
	tween(bottomBar, 0.5, { Size = UDim2.fromScale(1, 0) })
	tween(fader, 0.6, { BackgroundTransparency = 1 }).Completed:Wait()
	gui:Destroy()
	showHud()
	setControls(true)
	camera.CameraType = Enum.CameraType.Custom
end

return OpeningCutscene
