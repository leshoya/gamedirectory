--!strict
-- Drink-making minigames at the bubble tea bar, started by the server (server/Stations/DrinkStation).
--   Shake (milk tea, taro): alternate A and D (arrows, gamepad bumpers, or the on-screen buttons).
--   Whisk (matcha): move the mouse, a finger or the thumbstick in circles around the bowl.
-- The camera moves in close, a local cup or bowl reacts to every input, and a meter fills.
-- Finish fast for Perfect, a bit slower for Good; run out of time and it's Okay, or it spills.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)
local Sounds = require(script.Parent.Sounds)
local Controls = require(script.Parent.Controls)

local C = StoreConfig.Colors
local FX = StoreConfig.Effects
local METAL = Color3.fromRGB(215, 220, 230)

local DrinkMinigame = {}

local running = false

type Info = { Id: number, Kind: string, Item: string, Spot: BasePart, Target: number }

local function localPart(props: { [string]: any }): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.SmoothPlastic
	for key, value in props do
		(part :: any)[key] = value
	end
	part.Parent = workspace.CurrentCamera -- local only
	return part
end

local setControls = Controls.setEnabled

-- Hides the real station pieces around the spot (locally) so the minigame props can take their place.
local function hideAround(spot: BasePart, radius: number): { BasePart }
	local hidden = {}
	local parent = spot.Parent
	if not parent then
		return hidden
	end
	for _, d in parent:GetDescendants() do
		if d:IsA("BasePart") then
			local offset = d.Position - spot.Position
			if Vector2.new(offset.X, offset.Z).Magnitude <= radius and offset.Y > -0.5 and offset.Y < 2.5 then
				d.LocalTransparencyModifier = 1
				table.insert(hidden, d)
			end
		end
	end
	return hidden
end

local function buildUi(kind: string, itemName: string): (ScreenGui, Frame, Frame, TextLabel)
	local gui = Ui.screen("Minigame", 8)
	local panel = Ui.panel(gui, "Panel", UDim2.fromOffset(460, 132), UDim2.new(0.5, 0, 0, 24), Vector2.new(0.5, 0))
	local verb = if kind == "Whisk" then "Whisk the " else "Shake the "
	Ui.label(panel, verb .. itemName .. "!", UDim2.new(1, -24, 0, 34), UDim2.fromOffset(12, 8), C.Neon)
	local touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local how = if kind == "Whisk"
		then (if touch then "Drag your finger in circles around the bowl" else "Move your mouse in circles around the bowl")
		else (if touch then "Tap the left and right buttons, one after the other" else "Press A and D, one after the other")
	local instruction = Ui.label(panel, how, UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 44), C.SignText)
	instruction.Font = Enum.Font.GothamMedium

	local function bar(y: number, color: Color3): Frame
		local back = Instance.new("Frame")
		back.Size = UDim2.new(1, -40, 0, 16)
		back.Position = UDim2.fromOffset(20, y)
		back.BackgroundColor3 = Color3.fromRGB(240, 232, 245)
		back.Parent = panel
		Ui.corner(back, UDim.new(0.5, 0))
		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0, 1)
		fill.BackgroundColor3 = color
		fill.Parent = back
		Ui.corner(fill, UDim.new(0.5, 0))
		return fill
	end
	local progress = bar(74, C.Neon)
	local timer = bar(100, FX.TipGold)
	timer.Size = UDim2.fromScale(1, 1)

	local result = Ui.label(gui, "", UDim2.fromOffset(500, 90), UDim2.new(0.5, -250, 0.42, 0), FX.TipGold)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 4
	stroke.Parent = result
	return gui, progress, timer, result
end

-- The shaker you're holding: a steel tumbler with a tea-colored band and a dome cap.
local function shakerProp(at: CFrame, tea: Color3): { Part }
	local body = localPart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.6, 0.85, 0.85), Color = METAL, Material = Enum.Material.Metal })
	local band = localPart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 0.88, 0.88), Color = tea })
	local cap = localPart({ Size = Vector3.new(0.8, 0.5, 0.8), Color = METAL, Material = Enum.Material.Metal })
	Instance.new("SpecialMesh", cap).MeshType = Enum.MeshType.Sphere
	body.CFrame = at
	return { body, band, cap }
end

local function placeShaker(parts: { Part }, at: CFrame)
	local upright = CFrame.Angles(0, 0, math.rad(90))
	parts[1].CFrame = at * upright
	parts[2].CFrame = at * CFrame.new(0, -0.35, 0) * upright
	parts[3].CFrame = at * CFrame.new(0, 0.85, 0)
end

-- The matcha bowl, its surface (which foams up), and a bamboo whisk.
local function whiskProps(base: Vector3): (Part, Part, Part)
	local upright = CFrame.Angles(0, 0, math.rad(90))
	localPart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.7, 1.6, 1.6), CFrame = CFrame.new(base + Vector3.new(0, 0.35, 0)) * upright, Color = Color3.fromRGB(235, 225, 210) })
	local surface = localPart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.06, 1.4, 1.4), CFrame = CFrame.new(base + Vector3.new(0, 0.6, 0)) * upright, Color = Color3.fromRGB(95, 140, 70) })
	local handle = localPart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 0.22, 0.22), Color = StoreConfig.Colors.Wood })
	local tines = localPart({ Size = Vector3.new(0.5, 0.6, 0.5), Color = Color3.fromRGB(240, 225, 190) })
	Instance.new("SpecialMesh", tines).MeshType = Enum.MeshType.Sphere
	return surface, handle, tines
end

local function qualityFor(kind: string, elapsed: number, progress: number): string?
	local settings = (StoreConfig.Drinks :: any)[kind]
	if progress >= 1 then
		return if elapsed <= settings.PerfectTime then "Perfect" elseif elapsed <= settings.GoodTime then "Good" else "Okay"
	end
	return if progress >= StoreConfig.Drinks.SpillBelow then "Okay" else nil
end

function DrinkMinigame.run(info: Info)
	if running then
		return
	end
	running = true
	local settings = (StoreConfig.Drinks :: any)[info.Kind]
	local item = StoreConfig.Items[info.Item]
	local camera = workspace.CurrentCamera
	local spot = info.Spot
	local base = spot.Position - Vector3.new(0, spot.Size.X / 2, 0) -- spots are upright cylinders: X is their height
	local connections: { RBXScriptConnection } = {}

	setControls(false)
	local oldMouse = UserInputService.MouseBehavior
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	camera.CameraType = Enum.CameraType.Scriptable
	local focus = base + Vector3.new(0, 0.9, 0)
	TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { CFrame = CFrame.lookAt(focus + Vector3.new(0, 2.6, 4.2), focus) }):Play()
	local hidden = hideAround(spot, if info.Kind == "Whisk" then 1.6 else 0.6)

	local gui, progressBar, timerBar, resultLabel = buildUi(info.Kind, item.DisplayName)
	local progress, started, finished = 0, os.clock(), false
	local quality: string? = nil

	if info.Kind == "Shake" then
		local parts = shakerProp(CFrame.new(), item.CupColor)
		local home = CFrame.new(base + Vector3.new(0, 1.3, 0.6))
		local tilt, bounce, lastSide, shakes = 0, 0, 0, 0
		local function shake(side: number)
			if finished or side == lastSide then
				return
			end
			lastSide = side
			shakes += 1
			progress = math.min(1, shakes / info.Target)
			tilt = side * 0.45
			bounce = 0.35
			if shakes % 6 == 1 then
				Sounds.play("Shake", base)
			end
		end
		table.insert(connections, UserInputService.InputBegan:Connect(function(input, _)
			local key = input.KeyCode
			if key == Enum.KeyCode.A or key == Enum.KeyCode.Left or key == Enum.KeyCode.ButtonL1 then
				shake(-1)
			elseif key == Enum.KeyCode.D or key == Enum.KeyCode.Right or key == Enum.KeyCode.ButtonR1 then
				shake(1)
			end
		end))
		if UserInputService.TouchEnabled then
			Ui.button(gui, "< SHAKE", UDim2.fromOffset(170, 90), UDim2.new(0, 30, 1, -130), C.Neon, function()
				shake(-1)
			end)
			Ui.button(gui, "SHAKE >", UDim2.fromOffset(170, 90), UDim2.new(1, -200, 1, -130), C.Neon, function()
				shake(1)
			end)
		end
		table.insert(connections, RunService.RenderStepped:Connect(function(dt)
			tilt += (0 - tilt) * math.min(1, dt * 10)
			bounce += (0 - bounce) * math.min(1, dt * 8)
			placeShaker(parts, home * CFrame.new(0, bounce, 0) * CFrame.Angles(0, 0, tilt))
		end))
	else
		local surface, handle, tines = whiskProps(base)
		local light = Color3.fromRGB(205, 232, 165)
		local dark = surface.Color
		local lastAngle: number? = nil
		local turned = 0
		local touchPos: Vector2? = nil
		local stick = Vector2.zero
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				touchPos = Vector2.new(input.Position.X, input.Position.Y)
			elseif input.KeyCode == Enum.KeyCode.Thumbstick1 then
				stick = Vector2.new(input.Position.X, -input.Position.Y)
			end
		end))
		table.insert(connections, RunService.RenderStepped:Connect(function()
			local center3 = camera:WorldToViewportPoint(base + Vector3.new(0, 0.6, 0))
			local center = Vector2.new(center3.X, center3.Y)
			local offset: Vector2
			if stick.Magnitude > 0.5 then
				offset = stick * 100
			else
				local pointer = touchPos or UserInputService:GetMouseLocation()
				offset = pointer - center
			end
			if offset.Magnitude > 20 and not finished then
				local angle = math.atan2(offset.Y, offset.X)
				if lastAngle then
					local delta = (angle - lastAngle + math.pi) % (2 * math.pi) - math.pi
					if math.abs(delta) < 1.2 then
						turned += math.abs(delta)
					end
				end
				lastAngle = angle
				progress = math.min(1, turned / (2 * math.pi) / info.Target)
				-- Screen right is world +X and screen down is world +Z (toward the camera).
				local tip = base + Vector3.new(math.cos(angle) * 0.4, 0.75, math.sin(angle) * 0.4)
				tines.CFrame = CFrame.new(tip)
				handle.CFrame = CFrame.new(tip + Vector3.new(0, 0.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
			end
			surface.Color = dark:Lerp(light, progress)
			surface.Size = Vector3.new(0.06 + progress * 0.25, 1.4, 1.4)
		end))
	end

	-- Count down until done or out of time.
	while not finished do
		local elapsed = os.clock() - started
		progressBar.Size = UDim2.fromScale(progress, 1)
		local left = math.max(0, 1 - elapsed / settings.TimeLimit)
		timerBar.Size = UDim2.fromScale(left, 1)
		timerBar.BackgroundColor3 = if elapsed <= settings.PerfectTime then FX.TipGold elseif elapsed <= settings.GoodTime then FX.Good else FX.Bad
		if progress >= 1 or elapsed >= settings.TimeLimit then
			finished = true
			quality = qualityFor(info.Kind, elapsed, progress)
		end
		task.wait()
	end
	progressBar.Size = UDim2.fromScale(progress, 1)

	-- Tell the server, show the result, then put everything back.
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MinigameDone") :: RemoteFunction
	task.spawn(function()
		pcall(function()
			remote:InvokeServer(info.Id, quality)
		end)
	end)
	resultLabel.Text = if quality then string.upper(quality) .. "!" else "SPILLED!"
	resultLabel.TextColor3 = if quality == "Perfect" then FX.TipGold elseif quality == "Good" then FX.Good elseif quality then C.Neon else FX.Bad
	Ui.popIn(resultLabel)
	task.wait(0.9)

	for _, connection in connections do
		connection:Disconnect()
	end
	for _, child in camera:GetChildren() do
		if child:IsA("BasePart") then
			child:Destroy()
		end
	end
	for _, part in hidden do
		part.LocalTransparencyModifier = 0
	end
	gui:Destroy()
	UserInputService.MouseBehavior = oldMouse
	camera.CameraType = Enum.CameraType.Custom
	setControls(true)
	running = false
end

function DrinkMinigame.init()
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Minigame") :: RemoteEvent
	remote.OnClientEvent:Connect(function(info: Info)
		DrinkMinigame.run(info)
	end)
end

return DrinkMinigame
