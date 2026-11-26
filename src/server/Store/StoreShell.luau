--!strict
-- Floor, walls, front windows, ceiling lights, the outside sidewalk and the neon sign.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local FLOOR_Y = StoreConfig.FloorY

local StoreShell = {}

local function folder(parent: Instance, name: string): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local function buildFloor(parent: Instance)
	local floor = folder(parent, "Floor")
	local tile = S.FloorTile
	for ix = 0, S.Width // tile - 1 do
		for iz = 0, S.Depth // tile - 1 do
			local x = -S.Width / 2 + tile * (ix + 0.5)
			local z = -S.Depth / 2 + tile * (iz + 0.5)
			PartFactory.box(
				floor,
				"Tile",
				Vector3.new(tile, FLOOR_Y, tile),
				Vector3.new(x, 0, z),
				if (ix + iz) % 2 == 0 then C.FloorA else C.FloorB
			)
		end
	end
end

local function buildWalls(parent: Instance)
	local walls = folder(parent, "Walls")
	local t, h = S.WallThickness, S.WallHeight
	local halfW, halfD = S.Width / 2, S.Depth / 2
	local outerW = S.Width + 2 * t

	-- Back and sides
	PartFactory.box(walls, "BackWall", Vector3.new(outerW, h, t), Vector3.new(0, FLOOR_Y, -halfD - t / 2), C.Wall)
	PartFactory.box(walls, "LeftWall", Vector3.new(t, h, S.Depth), Vector3.new(-halfW - t / 2, FLOOR_Y, 0), C.Wall)
	PartFactory.box(walls, "RightWall", Vector3.new(t, h, S.Depth), Vector3.new(halfW + t / 2, FLOOR_Y, 0), C.Wall)

	-- Lavender stripe around the inside
	local stripeY = FLOOR_Y + 3.5
	PartFactory.box(walls, "Stripe", Vector3.new(S.Width, 0.6, 0.1), Vector3.new(0, stripeY, -halfD + 0.05), C.Trim)
	PartFactory.box(walls, "Stripe", Vector3.new(0.1, 0.6, S.Depth), Vector3.new(-halfW + 0.05, stripeY, 0), C.Trim)
	PartFactory.box(walls, "Stripe", Vector3.new(0.1, 0.6, S.Depth), Vector3.new(halfW - 0.05, stripeY, 0), C.Trim)

	-- Front: glass windows either side of the door opening, and a header above
	local frontZ = halfD + t / 2
	local windowW = (outerW - S.DoorWidth) / 2
	for side = -1, 1, 2 do
		local window = PartFactory.box(
			walls,
			"Window",
			Vector3.new(windowW, S.DoorHeight, t),
			Vector3.new(side * (S.DoorWidth / 2 + windowW / 2), FLOOR_Y, frontZ),
			C.Window,
			Enum.Material.Glass
		)
		-- Keep this at 0.2 or below: the player camera passes through more see-through parts,
		-- and would end up outside the store looking in through dark glass.
		window.Transparency = 0.2
	end
	PartFactory.box(
		walls,
		"Header",
		Vector3.new(outerW, h - S.DoorHeight, t),
		Vector3.new(0, FLOOR_Y + S.DoorHeight, frontZ),
		C.Trim
	)
end

local function buildCeiling(parent: Instance)
	local ceiling = folder(parent, "Ceiling")
	local topY = FLOOR_Y + S.WallHeight
	local t = S.WallThickness
	PartFactory.box(ceiling, "Ceiling", Vector3.new(S.Width + 2 * t, 1, S.Depth + 2 * t), Vector3.new(0, topY, 0), C.Ceiling)

	-- 3 x 2 grid of glowing panels
	for _, x in { -12, 0, 12 } do
		for _, z in { -7, 7 } do
			local panel = PartFactory.box(
				ceiling,
				"LightPanel",
				Vector3.new(6, 0.2, 2),
				Vector3.new(x, topY - 0.2, z),
				C.Light,
				Enum.Material.Neon
			)
			panel.CanCollide = false
			local light = Instance.new("PointLight")
			light.Color = C.Light
			light.Range = StoreConfig.Lighting.CeilingLightRange
			light.Brightness = StoreConfig.Lighting.CeilingLightBrightness
			light.Parent = panel
		end
	end
end

local function buildOutside(parent: Instance)
	local outside = folder(parent, "Outside")
	local frontEdge = S.Depth / 2 + S.WallThickness
	PartFactory.box(outside, "Sidewalk", Vector3.new(S.Width + 20, FLOOR_Y, 10), Vector3.new(0, 0, frontEdge + 5), C.Sidewalk)

	local sign = PartFactory.box(
		outside,
		"NeonSign",
		Vector3.new(16, 2.4, 0.4),
		Vector3.new(0, FLOOR_Y + S.DoorHeight + 0.3, frontEdge + 0.2),
		C.Neon,
		Enum.Material.Neon
	)
	-- The Back face points toward +Z, out to the street.
	PartFactory.label(sign, Enum.NormalId.Back, StoreConfig.SignText, Color3.new(1, 1, 1))

	local mat = PartFactory.box(outside, "DoorMat", Vector3.new(6, 0.05, 3), Vector3.new(0, FLOOR_Y, S.Depth / 2 - 2), C.Trim)
	mat.CanCollide = false
end

function StoreShell.build(parent: Instance)
	buildFloor(parent)
	buildWalls(parent)
	buildCeiling(parent)
	buildOutside(parent)
end

return StoreShell
