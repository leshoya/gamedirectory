--!strict
-- The building: checker floor, mint walls with pastel wainscoting and trim, framed front windows,
-- a ceiling with light panels, pastel string lights around the top of the walls, and bunting.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local L = StoreConfig.Layout
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
			PartFactory.box(floor, "Tile", Vector3.new(tile, FLOOR_Y, tile), Vector3.new(x, 0, z), if (ix + iz) % 2 == 0 then C.FloorA else C.FloorB)
		end
	end
end

-- Lower wall panels, a rail on top of them, and a baseboard, along one inside wall.
-- `along` is the wall's direction, `inward` points into the store, `length` is how long it is.
local function wallTrim(parent: Instance, center: Vector3, along: Vector3, inward: Vector3, length: number)
	local function strip(name: string, height: number, y: number, depth: number, color: Color3)
		local size = along * length + Vector3.new(0, height, 0) + inward:Abs() * depth
		local position = center + inward * (depth / 2) + Vector3.new(0, y, 0)
		PartFactory.box(parent, name, Vector3.new(math.abs(size.X), size.Y, math.abs(size.Z)), position, color)
	end
	strip("Wainscot", 3.6, FLOOR_Y, 0.12, C.Wainscot)
	strip("ChairRail", 0.35, FLOOR_Y + 3.6, 0.25, C.Trim)
	strip("Baseboard", 0.5, FLOOR_Y, 0.2, C.Trim)
	strip("CrownTrim", 0.4, FLOOR_Y + S.WallHeight - 0.4, 0.2, C.Trim)
end

local function buildWalls(parent: Instance)
	local walls = folder(parent, "Walls")
	local t, h = S.WallThickness, S.WallHeight
	local halfW, halfD = S.Width / 2, S.Depth / 2
	local outerW = S.Width + 2 * t

	PartFactory.box(walls, "BackWall", Vector3.new(outerW, h, t), Vector3.new(0, FLOOR_Y, -halfD - t / 2), C.Wall)
	PartFactory.box(walls, "LeftWall", Vector3.new(t, h, S.Depth), Vector3.new(-halfW - t / 2, FLOOR_Y, 0), C.Wall)
	PartFactory.box(walls, "RightWall", Vector3.new(t, h, S.Depth), Vector3.new(halfW + t / 2, FLOOR_Y, 0), C.Wall)

	wallTrim(walls, Vector3.new(0, 0, -halfD), Vector3.xAxis, Vector3.zAxis, S.Width)
	wallTrim(walls, Vector3.new(-halfW, 0, 0), Vector3.zAxis, Vector3.xAxis, S.Depth)
	wallTrim(walls, Vector3.new(halfW, 0, 0), Vector3.zAxis, -Vector3.xAxis, S.Depth)

	-- Front: framed glass windows either side of the door, and a header above
	local frontZ = halfD + t / 2
	local windowW = (outerW - S.DoorWidth) / 2
	for side = -1, 1, 2 do
		local centerX = side * (S.DoorWidth / 2 + windowW / 2)
		local window = PartFactory.box(walls, "Window", Vector3.new(windowW, S.DoorHeight, t), Vector3.new(centerX, FLOOR_Y, frontZ), C.Window, Enum.Material.Glass)
		-- Keep this at 0.2 or below: the player camera passes through more see-through parts,
		-- and would end up outside the store looking in through dark glass.
		window.Transparency = 0.2
		-- Window frame: a sill, and mullions splitting it into panes
		PartFactory.box(walls, "Sill", Vector3.new(windowW, 0.4, t + 0.6), Vector3.new(centerX, FLOOR_Y, frontZ), C.Trim)
		for i = 1, 3 do
			local x = centerX - windowW / 2 + windowW * i / 4
			PartFactory.box(walls, "Mullion", Vector3.new(0.3, S.DoorHeight, t + 0.2), Vector3.new(x, FLOOR_Y, frontZ), C.CounterTop)
		end
		PartFactory.box(walls, "Mullion", Vector3.new(windowW, 0.3, t + 0.2), Vector3.new(centerX, FLOOR_Y + S.DoorHeight * 0.62, frontZ), C.CounterTop)
	end
	PartFactory.box(walls, "Header", Vector3.new(outerW, h - S.DoorHeight, t), Vector3.new(0, FLOOR_Y + S.DoorHeight, frontZ), C.Trim)
	-- Door frame
	for side = -1, 1, 2 do
		PartFactory.box(walls, "DoorFrame", Vector3.new(0.5, S.DoorHeight, t + 0.4), Vector3.new(side * (S.DoorWidth / 2 + 0.25), FLOOR_Y, frontZ), C.Neon)
	end
end

local function buildCeiling(parent: Instance)
	local ceiling = folder(parent, "Ceiling")
	local topY = FLOOR_Y + S.WallHeight
	local t = S.WallThickness
	PartFactory.box(ceiling, "Ceiling", Vector3.new(S.Width + 2 * t, 1, S.Depth + 2 * t), Vector3.new(0, topY, 0), C.Ceiling)

	for _, x in L.CeilingLights.X do
		for _, z in L.CeilingLights.Z do
			PartFactory.box(ceiling, "PanelFrame", Vector3.new(7, 0.15, 2.8), Vector3.new(x, topY - 0.15, z), C.Trim)
			local panel = PartFactory.box(ceiling, "LightPanel", Vector3.new(6, 0.2, 2), Vector3.new(x, topY - 0.3, z), C.Light, Enum.Material.Neon)
			panel.CanCollide = false
			local light = Instance.new("PointLight")
			light.Color = C.Light
			light.Range = StoreConfig.Lighting.CeilingLightRange
			light.Brightness = StoreConfig.Lighting.CeilingLightBrightness
			light.Parent = panel
		end
	end
end

-- Little glowing bulbs along the top of the back and side walls, in rotating pastel colors.
-- Only every LightEvery-th bulb casts light, to keep the light count reasonable.
local function buildStringLights(parent: Instance)
	local lights = folder(parent, "StringLights")
	local y = FLOOR_Y + S.WallHeight - 1.3
	local halfW, halfD = S.Width / 2 - 0.4, S.Depth / 2 - 0.4
	local runs = {
		{ From = Vector3.new(-halfW, y, -halfD), To = Vector3.new(halfW, y, -halfD) },
		{ From = Vector3.new(-halfW, y, -halfD), To = Vector3.new(-halfW, y, halfD) },
		{ From = Vector3.new(halfW, y, -halfD), To = Vector3.new(halfW, y, halfD) },
	}
	local n = 0
	for _, run in runs do
		local length = (run.To - run.From).Magnitude
		local count = math.floor(length / L.StringLightSpacing)
		for i = 0, count do
			n += 1
			local sag = math.sin((i % 4) / 4 * math.pi) * 0.35 -- the wire droops between hooks
			local at = run.From:Lerp(run.To, i / count) - Vector3.new(0, sag, 0)
			local color = StoreConfig.Pastels[n % #StoreConfig.Pastels + 1]
			local bulb = Shapes.blob(lights, "Bulb", Vector3.new(0.35, 0.45, 0.35), CFrame.new(at), color, Enum.Material.Neon)
			if n % L.LightEvery == 0 then
				local glow = Instance.new("PointLight")
				glow.Color = color
				glow.Range = 7
				glow.Brightness = 0.6
				glow.Parent = bulb
			end
		end
	end
end

-- Strings of little triangle flags across the room, front to back.
local function buildBunting(parent: Instance)
	local bunting = folder(parent, "Bunting")
	local y = FLOOR_Y + S.WallHeight - 2
	for _, x in { -14, 0, 14 } do
		local from, to = Vector3.new(x, y, -S.Depth / 2 + 1), Vector3.new(x, y, S.Depth / 2 - 3)
		local length = (to - from).Magnitude
		local flags = math.floor(length / 1.6)
		for i = 0, flags do
			local t = i / flags
			local sag = math.sin(t * math.pi) * 1.2
			local at = from:Lerp(to, t) - Vector3.new(0, sag, 0)
			local color = StoreConfig.Pastels[i % #StoreConfig.Pastels + 1]
			-- A triangle pointing down, facing sideways across the room
			Shapes.triangle(bunting, "Flag", 1, 1, 0.05, CFrame.new(at - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, math.pi / 2, math.pi), color)
		end
	end
end

function StoreShell.build(parent: Instance)
	buildFloor(parent)
	buildWalls(parent)
	buildCeiling(parent)
	buildStringLights(parent)
	buildBunting(parent)
end

return StoreShell
