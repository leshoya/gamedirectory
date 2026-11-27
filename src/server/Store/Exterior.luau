--!strict
-- Outside the store: sidewalk and curb, a quiet road, a striped awning over the windows,
-- the neon sign, street lamps, flower planters and a bench by the door.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local FLOOR_Y = StoreConfig.FloorY

local Exterior = {}

local function lamp(parent: Instance, x: number, z: number)
	PartFactory.cup(parent, "LampPost", 9, 0.35, Vector3.new(x, 0, z), C.SignText)
	local head = Shapes.blob(parent, "LampGlobe", Vector3.new(1.4, 1.4, 1.4), CFrame.new(x, 9.6, z), C.Light, Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 225, 200)
	light.Range = 22
	light.Brightness = 1.4
	light.Parent = head
end

local function planter(parent: Instance, x: number, z: number, rng: Random)
	PartFactory.box(parent, "Planter", Vector3.new(3, 1.4, 1.4), Vector3.new(x, FLOOR_Y, z), C.Pot)
	for i = -1, 1 do
		Shapes.blob(parent, "Bush", Vector3.new(1.3, 1.1, 1.2), CFrame.new(x + i * 0.9, FLOOR_Y + 1.9, z), C.Leaf)
		local flower = StoreConfig.Pastels[rng:NextInteger(1, #StoreConfig.Pastels)]
		Shapes.blob(parent, "Flower", Vector3.new(0.4, 0.4, 0.4), CFrame.new(x + i * 0.9 + 0.2, FLOOR_Y + 2.45, z - 0.3), flower, Enum.Material.SmoothPlastic)
	end
end

local function bench(parent: Instance, x: number, z: number)
	PartFactory.box(parent, "BenchSeat", Vector3.new(4, 0.3, 1.2), Vector3.new(x, FLOOR_Y + 1.4, z), C.Wood)
	PartFactory.box(parent, "BenchBack", Vector3.new(4, 1.2, 0.2), Vector3.new(x, FLOOR_Y + 1.8, z + 0.55), C.Wood)
	for side = -1, 1, 2 do
		PartFactory.box(parent, "BenchLeg", Vector3.new(0.3, 1.4, 1), Vector3.new(x + side * 1.7, FLOOR_Y, z), C.Trim)
	end
end

function Exterior.build(parent: Instance)
	local outside = Instance.new("Folder")
	outside.Name = "Outside"
	outside.Parent = parent
	local rng = Random.new(5)
	local frontEdge = S.Depth / 2 + S.WallThickness
	local width = S.Width + 30

	-- Ground: sidewalk, curb, road with a dashed center line
	PartFactory.box(outside, "Sidewalk", Vector3.new(width, FLOOR_Y, 12), Vector3.new(0, 0, frontEdge + 6), C.Sidewalk)
	PartFactory.box(outside, "Curb", Vector3.new(width, FLOOR_Y + 0.1, 0.6), Vector3.new(0, 0, frontEdge + 12.3), C.CounterTop)
	PartFactory.box(outside, "Road", Vector3.new(width, 0.1, 16), Vector3.new(0, 0, frontEdge + 20.6), C.Road)
	for i = -6, 6 do
		PartFactory.box(outside, "LaneDash", Vector3.new(3, 0.05, 0.35), Vector3.new(i * 7, 0.1, frontEdge + 20.6), C.Light)
	end

	-- Striped awning sloping out over each window
	local windowW = (S.Width + 2 * S.WallThickness - S.DoorWidth) / 2
	local stripes = math.floor(windowW / 2)
	for side = -1, 1, 2 do
		local centerX = side * (S.DoorWidth / 2 + windowW / 2)
		for i = 0, stripes - 1 do
			local x = centerX - windowW / 2 + (i + 0.5) * windowW / stripes
			local stripe = PartFactory.part({
				Name = "Awning",
				Size = Vector3.new(windowW / stripes, 0.2, 3.2),
				CFrame = CFrame.new(x, FLOOR_Y + S.DoorHeight + 0.2, frontEdge + 1.4) * CFrame.Angles(math.rad(-20), 0, 0),
				Color = if i % 2 == 0 then C.Neon else C.CounterTop,
				Material = Enum.Material.Fabric,
				Parent = outside,
			})
			stripe.CastShadow = true
			-- Scalloped edge
			Shapes.blob(outside, "AwningScallop", Vector3.new(windowW / stripes, 0.6, 0.25), CFrame.new(x, FLOOR_Y + S.DoorHeight - 0.45, frontEdge + 2.9), stripe.Color, Enum.Material.Fabric)
		end
	end

	-- The neon sign over the door. The Back face points toward +Z, out to the street.
	local sign = PartFactory.box(outside, "NeonSign", Vector3.new(16, 2.4, 0.4), Vector3.new(0, FLOOR_Y + S.DoorHeight + 1.2, frontEdge + 0.2), C.Neon, Enum.Material.Neon)
	PartFactory.label(sign, Enum.NormalId.Back, StoreConfig.SignText, Color3.new(1, 1, 1))
	local glow = Instance.new("PointLight")
	glow.Color = C.Neon
	glow.Range = 16
	glow.Brightness = 1.2
	glow.Parent = sign

	-- A HELP WANTED sign taped to the window beside the door (the opening cutscene looks at it).
	local help = PartFactory.part({
		Name = "HelpWanted",
		Size = Vector3.new(3.2, 2.2, 0.05),
		CFrame = CFrame.new(-7.5, FLOOR_Y + 4.6, frontEdge + 0.03),
		Color = Color3.fromRGB(255, 250, 240),
		CanCollide = false,
		Parent = outside,
	})
	local helpGui = Instance.new("SurfaceGui")
	helpGui.Face = Enum.NormalId.Back -- +Z, out to the street
	helpGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	helpGui.PixelsPerStud = 50
	helpGui.LightInfluence = 0.4
	helpGui.Parent = help
	for i, line in { "HELP WANTED", "Night shift", "Must love plushies" } do
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(0.9, if i == 1 then 0.4 else 0.22)
		text.Position = UDim2.fromScale(0.05, if i == 1 then 0.06 else 0.26 + i * 0.2)
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.FredokaOne
		text.TextScaled = true
		text.TextColor3 = if i == 1 then Color3.fromRGB(230, 70, 120) else C.SignText
		text.Text = line
		text.Parent = helpGui
	end

	local mat = PartFactory.box(outside, "DoorMat", Vector3.new(6, 0.05, 3), Vector3.new(0, FLOOR_Y, S.Depth / 2 - 2), C.Trim)
	mat.CanCollide = false

	for _, x in { -S.Width / 2 - 4, S.Width / 2 + 4, -10, 10 } do
		lamp(outside, x, frontEdge + 11)
	end
	for _, x in { -S.Width / 4, S.Width / 4 } do
		planter(outside, x, frontEdge + 1.6, rng)
	end
	bench(outside, -8, frontEdge + 4)
	bench(outside, 8, frontEdge + 4)
end

return Exterior
