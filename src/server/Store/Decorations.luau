--!strict
-- Cozy extras that make the store nice to be in: a window bar with stools and paper lanterns,
-- capsule-toy machines, potted plants, a plush display shelf, posters, a wall clock and a rug.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)
local PlushRig = require(script.Parent.Parent.Plush.PlushRig)
local Accessories = require(script.Parent.Parent.Plush.Accessories)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local L = StoreConfig.Layout
local FLOOR_Y = StoreConfig.FloorY

local Decorations = {}

local function pastel(rng: Random): Color3
	return StoreConfig.Pastels[rng:NextInteger(1, #StoreConfig.Pastels)]
end

local function windowBar(parent: Instance, rng: Random)
	local from, to = L.WindowBar.FromX, L.WindowBar.ToX
	local length = to - from
	local x = (from + to) / 2
	local z = S.Depth / 2 - 1.2
	PartFactory.box(parent, "BarTop", Vector3.new(length, 0.3, 1.6), Vector3.new(x, FLOOR_Y + 3.6, z), C.Wood)
	for _, px in { from + 0.5, to - 0.5 } do
		PartFactory.box(parent, "BarLeg", Vector3.new(0.4, 3.6, 1.2), Vector3.new(px, FLOOR_Y, z), C.Trim)
	end
	local stools = math.floor(length / 3)
	for i = 0, stools - 1 do
		local sx = from + 1.5 + i * 3
		PartFactory.cup(parent, "StoolLeg", 2.4, 0.3, Vector3.new(sx, FLOOR_Y, z - 1.8), C.Trim)
		PartFactory.cup(parent, "StoolSeat", 0.35, 1.3, Vector3.new(sx, FLOOR_Y + 2.4, z - 1.8), pastel(rng))
	end
	-- Paper lanterns hanging over the bar
	for i = 0, 3 do
		local lx = from + 2.5 + i * (length - 5) / 3
		local topY = FLOOR_Y + S.WallHeight
		PartFactory.part({ Name = "LanternCord", Size = Vector3.new(0.05, 3, 0.05), CFrame = CFrame.new(lx, topY - 1.5, z), Color = C.SignText, CanCollide = false, Parent = parent })
		local lantern = Shapes.blob(parent, "Lantern", Vector3.new(1.4, 1.7, 1.4), CFrame.new(lx, topY - 3.8, z), pastel(rng), Enum.Material.Neon)
		local glow = Instance.new("PointLight")
		glow.Color = lantern.Color
		glow.Range = 9
		glow.Brightness = 0.7
		glow.Parent = lantern
	end
end

-- A capsule-toy machine: a glass globe of capsules on a pastel stand.
local function capsuleMachine(parent: Instance, x: number, z: number, color: Color3, rng: Random)
	PartFactory.box(parent, "CapsuleBase", Vector3.new(2, 3.2, 2), Vector3.new(x, FLOOR_Y, z), color)
	PartFactory.box(parent, "CapsuleDial", Vector3.new(0.7, 0.7, 0.2), Vector3.new(x, FLOOR_Y + 1.8, z - 1.05), C.CounterTop)
	local globe = Shapes.blob(parent, "CapsuleGlobe", Vector3.new(2.2, 2.2, 2.2), CFrame.new(x, FLOOR_Y + 4.3, z), C.Window, Enum.Material.Glass)
	globe.Transparency = 0.55
	for _ = 1, 10 do
		local offset = Vector3.new(rng:NextNumber(-0.6, 0.6), rng:NextNumber(-0.7, 0.1), rng:NextNumber(-0.6, 0.6))
		Shapes.blob(parent, "Capsule", Vector3.one * 0.45, CFrame.new(Vector3.new(x, FLOOR_Y + 4.3, z) + offset), pastel(rng), Enum.Material.SmoothPlastic)
	end
	PartFactory.cup(parent, "CapsuleCap", 0.3, 1, Vector3.new(x, FLOOR_Y + 5.35, z), color)
end

local function plant(parent: Instance, x: number, z: number, rng: Random)
	PartFactory.cup(parent, "Pot", 1.4, 1.5, Vector3.new(x, FLOOR_Y, z), C.Pot)
	for i = 1, 5 do
		local angle = i / 5 * math.pi * 2
		local leaf = CFrame.new(x + math.cos(angle) * 0.5, FLOOR_Y + 2.3, z + math.sin(angle) * 0.5) * CFrame.Angles(math.sin(angle) * 0.6, 0, -math.cos(angle) * 0.6)
		Shapes.blob(parent, "Leaf", Vector3.new(0.6, 1.8, 0.3), leaf, C.Leaf)
	end
	Shapes.blob(parent, "Bloom", Vector3.one * 0.45, CFrame.new(x, FLOOR_Y + 3.3, z), pastel(rng), Enum.Material.SmoothPlastic)
end

-- A wall shelf of little plush toys for sale, high on the left wall.
local function plushShelf(parent: Instance, rng: Random)
	local x = -S.Width / 2 + 0.9
	local z, y = -4, FLOOR_Y + 6.5
	PartFactory.box(parent, "PlushShelf", Vector3.new(1.6, 0.25, 12), Vector3.new(x, y, z), C.Wood)
	local species = StoreConfig.Customers.SpeciesPool
	for i, name in species do
		local plush = PlushRig.build(name, {
			Accessory = Accessories.Kinds[rng:NextInteger(1, #Accessories.Kinds)],
			AccessoryColor = pastel(rng),
			Scale = 0.32,
		}, rng)
		local at = Vector3.new(x + 0.1, y + 0.25, z - 5 + (i - 1) * 2.5)
		plush.Model:PivotTo(CFrame.lookAt(at, at + Vector3.xAxis))
		plush.Model.Parent = parent
	end
	local sign = PartFactory.box(parent, "PlushSign", Vector3.new(0.1, 0.9, 5), Vector3.new(x - 0.5, y + 2.6, z), C.Neon)
	PartFactory.label(sign, Enum.NormalId.Right, "TAKE ONE HOME", Color3.new(1, 1, 1))
end

local function poster(parent: Instance, position: Vector3, face: Enum.NormalId, size: Vector3, color: Color3, title: string, line: string)
	local part = PartFactory.part({ Name = "Poster", Size = size, CFrame = CFrame.new(position), Color = color, Parent = parent })
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.3
	gui.Parent = part
	for i, text in { title, line } do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(0.9, if i == 1 then 0.45 else 0.3)
		label.Position = UDim2.fromScale(0.05, if i == 1 then 0.1 else 0.6)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextScaled = true
		label.TextColor3 = if i == 1 then Color3.new(1, 1, 1) else C.SignText
		label.Text = text
		label.Parent = gui
	end
end

local function clock(parent: Instance)
	local at = Vector3.new(-6, FLOOR_Y + 9.5, -S.Depth / 2 + 0.15)
	local face = PartFactory.part({ Name = "Clock", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 2.2, 2.2), CFrame = CFrame.new(at) * CFrame.Angles(0, math.rad(90), 0), Color = C.CounterTop, Parent = parent })
	face.CastShadow = false
	PartFactory.part({ Name = "ClockRim", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.15, 2.5, 2.5), CFrame = CFrame.new(at - Vector3.new(0, 0, 0.05)) * CFrame.Angles(0, math.rad(90), 0), Color = C.Neon, Parent = parent })
	-- Hands stuck at a few minutes to midnight
	Shapes.bar(parent, "HourHand", Vector3.new(0.12, 0.6, 0.05), CFrame.new(at + Vector3.new(0, 0.3, 0.15)), C.SignText)
	Shapes.bar(parent, "MinuteHand", Vector3.new(0.08, 0.9, 0.05), CFrame.new(at + Vector3.new(0, 0, 0.15)) * CFrame.Angles(0, 0, math.rad(20)) * CFrame.new(0, 0.42, 0), C.SignText)
end

function Decorations.build(parent: Instance)
	local folder = Instance.new("Folder")
	folder.Name = "Decorations"
	folder.Parent = parent
	local rng = Random.new(77)
	local halfW, halfD = S.Width / 2, S.Depth / 2

	windowBar(folder, rng)
	capsuleMachine(folder, 22, 17.5, C.Neon, rng)
	capsuleMachine(folder, 25, 17.5, StoreConfig.Pastels[2], rng)
	for _, spot in { Vector2.new(-halfW + 1.5, -halfD + 4.5), Vector2.new(-5.5, -halfD + 1.5), Vector2.new(halfW - 1.5, 10.5), Vector2.new(-halfW + 1.5, 13) } do
		plant(folder, spot.X, spot.Y, rng)
	end
	plushShelf(folder, rng)
	poster(folder, Vector3.new(-halfW + 0.1, FLOOR_Y + 6.5, 9), Enum.NormalId.Right, Vector3.new(0.1, 3, 4), C.Neon, "NEW!", "Taro bubble tea")
	poster(folder, Vector3.new(halfW - 0.1, FLOOR_Y + 9.5, -16), Enum.NormalId.Left, Vector3.new(0.1, 3, 4), StoreConfig.Pastels[2], "BE KIND", "to every customer")
	poster(folder, Vector3.new(11, FLOOR_Y + 9.5, -halfD + 0.1), Enum.NormalId.Back, Vector3.new(4, 3, 0.1), StoreConfig.Pastels[4], "OPEN 24H", "see you at midnight")
	clock(folder)
	local rug = PartFactory.box(folder, "Rug", Vector3.new(12, 0.06, 5), Vector3.new(-8, FLOOR_Y, 13.5), C.Trim)
	rug.CanCollide = false
	local rugInner = PartFactory.box(folder, "RugInner", Vector3.new(11, 0.07, 4), Vector3.new(-8, FLOOR_Y, 13.5), C.Wainscot)
	rugInner.CanCollide = false
end

return Decorations
