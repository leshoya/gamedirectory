--!strict
-- Manager Mochi's welcome: a short camera tour of the store with dialogue that explains the job.
-- Plays once for new workers (the server remembers via the "SeenIntro" attribute) and again
-- whenever the Help button is pressed. Next advances, Skip ends it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)

local C = StoreConfig.Colors

type Shot = { Text: string, Camera: Vector3, LookAt: Vector3 }

local Intro = {}

local playing = false

-- Camera shots, built from the store layout so they follow it if it changes.
local function shots(manager: Model): { Shot }
	local m = manager:GetPivot().Position
	local face = m + Vector3.new(0, 6.5, 0)
	local close = m + Vector3.new(-3, 7, 10)
	local reg = StoreConfig.Register.Position
	local L = StoreConfig.Layout
	local breaker = StoreConfig.Power.BreakerPosition
	return {
		{ Text = "Oh! You must be the new night-shift hire. Welcome to Plushie Mart! I'm Manager Mochi.", Camera = close, LookAt = face },
		{ Text = "Our customers are plushies from all over town. They come to the register and order bubble tea or hot ramen.", Camera = reg + Vector3.new(6, 7, 12), LookAt = reg + Vector3.new(0, 3, 2) },
		{ Text = "Make drinks at the bubble tea bar and ramen at the hot water station. Hold E to make one.", Camera = Vector3.new(L.BubbleTeaX + 9, 8, -6), LookAt = Vector3.new(L.BubbleTeaX + 9, 4, -18) },
		{ Text = "Bring the order to the customer and press E to serve them. Fast service and streaks earn extra tips!", Camera = reg + Vector3.new(-2, 6, 12), LookAt = reg + Vector3.new(2, 4, 3) },
		{ Text = "But after midnight... some customers aren't quite right. An extra ear. The wrong color. A smile stitched too wide.", Camera = m + Vector3.new(2, 5, 6), LookAt = face },
		{ Text = "If something's wrong, never serve it. Press F: 'Sorry, we're closed.' Each one you spot fills a page in your Rulebook.", Camera = reg + Vector3.new(4, 6, 11), LookAt = reg + Vector3.new(0, 4, 4) },
		{ Text = "Mistakes fill the Dread meter. If it fills, the lights go out. Hold E at the breaker by the door before they get close.", Camera = breaker + Vector3.new(-9, 4, -6), LookAt = breaker + Vector3.new(0, 3, 0) },
		{ Text = "Survive five nights and you'll see the sunrise. Good luck! And... try not to stay late.", Camera = close + Vector3.new(0, -1, -3), LookAt = face },
	}
end

local function typewrite(label: TextLabel, text: string, skipped: () -> boolean)
	label.Text = text
	label.MaxVisibleGraphemes = 0
	for i = 1, #text do
		if skipped() then
			break
		end
		label.MaxVisibleGraphemes = i
		task.wait(0.018)
	end
	label.MaxVisibleGraphemes = -1
end

function Intro.play()
	if playing then
		return
	end
	local store = workspace:WaitForChild("Store")
	local manager = store:WaitForChild("Manager", 30) :: Model?
	if not manager then
		return
	end
	playing = true
	local camera = workspace.CurrentCamera
	local gui = Ui.screen("Intro", 10)

	-- Hide the regular HUD while the manager talks.
	local hidden = {}
	for _, other in Players.LocalPlayer.PlayerGui:GetChildren() do
		if other:IsA("ScreenGui") and other ~= gui and other.Enabled then
			other.Enabled = false
			table.insert(hidden, other)
		end
	end

	local box = Ui.panel(gui, "Dialogue", UDim2.new(0.6, 0, 0, 190), UDim2.new(0.5, 0, 1, -24), Vector2.new(0.5, 1))
	local nameTag = Ui.panel(box, "Name", UDim2.fromOffset(220, 40), UDim2.fromOffset(20, -24))
	nameTag.BackgroundColor3 = C.Neon
	Ui.label(nameTag, "Manager Mochi", UDim2.new(1, -16, 1, -8), UDim2.fromOffset(8, 4), Color3.new(1, 1, 1))
	local text = Ui.label(box, "", UDim2.new(1, -48, 1, -88), UDim2.fromOffset(24, 28), C.SignText, Enum.TextXAlignment.Left)
	text.TextScaled = false
	text.TextSize = 24
	text.TextWrapped = true
	text.TextYAlignment = Enum.TextYAlignment.Top

	local advance = Instance.new("BindableEvent")
	local skipped = false
	local nextButton = Ui.button(box, "Next", UDim2.fromOffset(120, 40), UDim2.new(1, -140, 1, -52), C.Neon, function()
		advance:Fire()
	end)
	Ui.button(box, "Skip", UDim2.fromOffset(100, 40), UDim2.new(1, -250, 1, -52), C.Trim, function()
		skipped = true
		advance:Fire()
	end)
	Ui.popIn(box)

	camera.CameraType = Enum.CameraType.Scriptable
	local list = shots(manager)
	for i, shot in list do
		if skipped then
			break
		end
		local goal = CFrame.lookAt(shot.Camera, shot.LookAt)
		if i == 1 then
			camera.CFrame = goal * CFrame.new(0, 2, 6)
		end
		TweenService:Create(camera, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { CFrame = goal }):Play()
		nextButton.Text = if i == #list then "Let's go!" else "Next"
		local done = false
		task.spawn(typewrite, text, shot.Text, function()
			return done or skipped
		end)
		advance.Event:Wait()
		done = true
	end

	gui:Destroy()
	for _, other in hidden do
		other.Enabled = true
	end
	camera.CameraType = Enum.CameraType.Custom
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
	playing = false
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("IntroDone") :: RemoteEvent
	remote:FireServer()
end

-- Plays the intro for workers who haven't seen it, once their saved data has loaded.
function Intro.init()
	local player = Players.LocalPlayer
	while player:GetAttribute("SeenIntro") == nil do
		player:GetAttributeChangedSignal("SeenIntro"):Wait()
	end
	if not player:GetAttribute("SeenIntro") then
		if not player.Character then
			player.CharacterAdded:Wait()
		end
		task.wait(1)
		Intro.play()
	end
end

return Intro
