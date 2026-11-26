--!strict
-- The store's sections: three stocked aisles (Snacks, Sweets, Noodles) with hanging signs,
-- the Cold Drinks cooler, ice cream chest freezers, the bubble tea bar and ramen station with
-- menu boards, the staff door, and the breaker box.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local Packaging = require(script.Parent.Packaging)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local L = StoreConfig.Layout
local FLOOR_Y = StoreConfig.FloorY
local BACK_Z = -S.Depth / 2
local SIGN_Y = FLOOR_Y + S.WallHeight - 3.2

local Fixtures = {}

local function model(parent: Instance, name: string): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

local function pastel(rng: Random): Color3
	return StoreConfig.Pastels[rng:NextInteger(1, #StoreConfig.Pastels)]
end

-- Stocks one shelf board with a row of products along Z, facing out on `side` (-1 or 1 in X).
type Stocker = (parent: Instance, bottom: Vector3, facing: Vector3, rng: Random) -> ()

local STOCK: { [string]: { Stocker } } = {
	Snacks = {
		function(parent, bottom, facing, rng)
			Packaging.box(parent, bottom, facing, Vector3.new(1.1, 1.3, 0.5), pastel(rng), rng)
		end,
		function(parent, bottom, facing, rng)
			Packaging.bag(parent, bottom, facing, pastel(rng))
		end,
	},
	Sweets = {
		function(parent, bottom, _, rng)
			Packaging.jar(parent, bottom, rng)
		end,
		function(parent, bottom, facing, rng)
			Packaging.box(parent, bottom, facing, Vector3.new(1.1, 0.9, 0.5), pastel(rng), rng)
		end,
	},
	Noodles = {
		function(parent, bottom, _, rng)
			Packaging.cupNoodle(parent, bottom, pastel(rng))
		end,
		function(parent, bottom, facing, rng)
			Packaging.box(parent, bottom, facing, Vector3.new(1.1, 1.1, 0.5), pastel(rng), rng)
		end,
	},
}

-- A two-sided aisle shelf running along Z, with an end cap color stripe and a hanging sign.
local function buildShelf(parent: Instance, x: number, section: string, title: string, rng: Random)
	local z, length = L.Shelves.Z, L.Shelves.Length
	local shelf = model(parent, section .. "Shelf")
	PartFactory.box(shelf, "Back", Vector3.new(0.4, 6.6, length), Vector3.new(x, FLOOR_Y, z), C.Shelf)
	PartFactory.box(shelf, "Base", Vector3.new(3.6, 0.6, length), Vector3.new(x, FLOOR_Y, z), C.Trim)
	PartFactory.box(shelf, "TopCap", Vector3.new(3.8, 0.3, length + 0.2), Vector3.new(x, FLOOR_Y + 6.6, z), C.Trim)
	for side = -1, 1, 2 do
		PartFactory.box(shelf, "EndCap", Vector3.new(3.6, 6.6, 0.3), Vector3.new(x, FLOOR_Y, z + side * (length / 2 + 0.15)), C.Neon)
	end

	local stockers = STOCK[section]
	local slots = math.floor(length / 1.3)
	for level = 1, 3 do
		local boardY = FLOOR_Y + level * 1.95 - 0.9
		PartFactory.box(shelf, "Board", Vector3.new(3.6, 0.2, length), Vector3.new(x, boardY, z), C.Shelf)
		for side = -1, 1, 2 do
			-- Price strip on the board's edge
			PartFactory.box(shelf, "PriceStrip", Vector3.new(0.05, 0.2, length), Vector3.new(x + side * 1.82, boardY, z), C.CounterTop)
			for i = 0, slots - 1 do
				local pz = z - length / 2 + 0.65 + i * 1.3
				local stocker = stockers[(i + level) % #stockers + 1]
				stocker(shelf, Vector3.new(x + side * 1.05, boardY + 0.2, pz), Vector3.new(side, 0, 0), rng)
			end
		end
	end
	Packaging.hangingSign(parent, Vector3.new(x, SIGN_Y, z + length / 2 - 1), 6, title, C.Neon, true)
end

-- Glass-door drinks cooler along the right wall, stocked with bottles and cans.
local function buildCooler(parent: Instance, rng: Random)
	local cooler = model(parent, "ColdDrinks")
	local depth, height, length = 3, 8.5, L.Fridge.Length
	local x = S.Width / 2 - depth / 2
	local z = L.Fridge.Z
	local front = x - depth / 2
	PartFactory.box(cooler, "Body", Vector3.new(depth, height, length), Vector3.new(x, FLOOR_Y, z), C.Fridge)
	PartFactory.box(cooler, "Inside", Vector3.new(0.1, height - 1.2, length - 0.6), Vector3.new(front + 0.3, FLOOR_Y + 0.6, z), C.CounterTop)

	for level = 0, 3 do
		local y = FLOOR_Y + 0.6 + level * 1.9
		PartFactory.box(cooler, "CoolerShelf", Vector3.new(1.6, 0.1, length - 0.6), Vector3.new(front + 0.9, y, z), C.Window)
		for i = 0, math.floor((length - 1) / 0.6) - 1 do
			local pz = z - length / 2 + 0.8 + i * 0.6
			local at = Vector3.new(front + 0.9, y + 0.1, pz)
			if level % 2 == 0 then
				Packaging.bottle(cooler, at, pastel(rng))
			else
				Packaging.can(cooler, at, pastel(rng))
			end
		end
	end

	local doors = 5
	local doorLength = length / doors
	for i = 0, doors - 1 do
		local dz = z - length / 2 + doorLength * (i + 0.5)
		local door = PartFactory.box(cooler, "Door", Vector3.new(0.15, height - 1, doorLength - 0.25), Vector3.new(front - 0.08, FLOOR_Y + 0.5, dz), C.Window, Enum.Material.Glass)
		door.Transparency = 0.2
		PartFactory.box(cooler, "Handle", Vector3.new(0.15, 2.2, 0.15), Vector3.new(front - 0.3, FLOOR_Y + 3.2, dz + doorLength / 2 - 0.4), C.CounterTop)
	end
	local glow = PartFactory.box(cooler, "Glow", Vector3.new(0.3, 0.3, length - 0.4), Vector3.new(front - 0.15, FLOOR_Y + height - 0.4, z), C.Light, Enum.Material.Neon)
	glow.CanCollide = false
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Color = Color3.fromRGB(220, 240, 255)
	light.Range = 8
	light.Brightness = 0.8
	light.Parent = glow
	Packaging.hangingSign(parent, Vector3.new(front - 2, SIGN_Y, z), 8, "COLD DRINKS", Color3.fromRGB(120, 190, 240), true)
end

-- A chest freezer of ice cream tubs under a glass lid.
local function buildFreezer(parent: Instance, x: number, z: number, rng: Random)
	local freezer = model(parent, "IceCreamFreezer")
	local size = Vector3.new(5, 3, 2.6)
	PartFactory.box(freezer, "Body", size, Vector3.new(x, FLOOR_Y, z), C.CounterTop)
	PartFactory.box(freezer, "Stripe", Vector3.new(size.X + 0.02, 0.5, size.Z + 0.02), Vector3.new(x, FLOOR_Y + 1.6, z), C.Neon)
	for i = 0, 3 do
		for j = 0, 1 do
			local tub = PartFactory.cup(freezer, "Tub", 0.6, 0.9, Vector3.new(x - 1.7 + i * 1.15, FLOOR_Y + 2.2, z - 0.5 + j * 1), pastel(rng))
			tub.Material = Enum.Material.SmoothPlastic
		end
	end
	local lid = PartFactory.box(freezer, "Lid", Vector3.new(size.X, 0.15, size.Z), Vector3.new(x, FLOOR_Y + size.Y, z), C.Window, Enum.Material.Glass)
	lid.Transparency = 0.35
	local sign = PartFactory.box(freezer, "Sign", Vector3.new(3, 0.8, 0.1), Vector3.new(x, FLOOR_Y + 0.5, z + size.Z / 2 + 0.05), C.Trim)
	PartFactory.label(sign, Enum.NormalId.Back, "ICE CREAM", Color3.new(1, 1, 1))
end

-- A menu board on the back wall: a title and a few items.
local function menuBoard(parent: Instance, x: number, title: string, items: { string })
	local board = PartFactory.box(parent, "MenuBoard", Vector3.new(8, 3.6, 0.2), Vector3.new(x, FLOOR_Y + 6.2, BACK_Z + 0.1), C.Screen)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- +Z, into the store
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = board
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = gui
	for i, line in { title, table.unpack(items) } do
		local text = Instance.new("TextLabel")
		text.LayoutOrder = i
		text.Size = UDim2.fromScale(0.9, if i == 1 then 0.34 else 0.2)
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.FredokaOne
		text.TextScaled = true
		text.TextColor3 = if i == 1 then C.Neon else C.ScreenText
		text.Text = line
		text.Parent = gui
	end
end

-- A counter against the back wall. Returns the model and the countertop height.
local function buildStation(parent: Instance, name: string, x: number, width: number): (Model, number)
	local station = model(parent, name)
	local depth, height = 3, 3.5
	local z = BACK_Z + depth / 2
	PartFactory.box(station, "Counter", Vector3.new(width, height, depth), Vector3.new(x, FLOOR_Y, z), C.Counter)
	PartFactory.box(station, "Top", Vector3.new(width + 0.4, 0.3, depth + 0.4), Vector3.new(x, FLOOR_Y + height, z), C.CounterTop)
	PartFactory.box(station, "Kick", Vector3.new(width, 0.4, 0.1), Vector3.new(x, FLOOR_Y, BACK_Z + depth + 0.05), C.Trim)
	return station, FLOOR_Y + height + 0.3
end

local function buildBubbleTea(parent: Instance, rng: Random): BasePart
	local x = L.BubbleTeaX
	local station, topY = buildStation(parent, "BubbleTeaBar", x, 12)
	local front = BACK_Z + 1.6
	local flavors = { Color3.fromRGB(230, 200, 170), Color3.fromRGB(200, 170, 240), Color3.fromRGB(190, 230, 170), Color3.fromRGB(255, 190, 200) }
	for i, color in flavors do
		PartFactory.cup(station, "Cup", 1.4, 0.9, Vector3.new(x - 5.5 + i * 1.1, topY, front), color)
	end
	-- Syrup bottles along the back
	for i = 0, 5 do
		Packaging.bottle(station, Vector3.new(x - 2 + i * 0.7, topY, BACK_Z + 0.6), pastel(rng))
	end
	-- Jars of tapioca pearls
	for i = 0, 1 do
		local jar = PartFactory.cup(station, "PearlJar", 1.1, 1, Vector3.new(x + 3 + i * 1.2, topY, front - 0.3), Color3.fromRGB(240, 245, 255))
		jar.Material = Enum.Material.Glass
		jar.Transparency = 0.45
		for k = 1, 5 do
			Shapes.blob(station, "Pearl", Vector3.one * 0.3, CFrame.new(x + 3 + i * 1.2 + rng:NextNumber(-0.2, 0.2), topY + 0.15 + k * 0.12, front - 0.3 + rng:NextNumber(-0.2, 0.2)), Color3.fromRGB(70, 45, 50), Enum.Material.SmoothPlastic)
		end
	end
	menuBoard(station, x, "BUBBLE TEA", { "Milk Tea   3 hearts", "Taro   3 hearts", "Matcha   4 hearts" })
	return PartFactory.box(station, "Shaker", Vector3.new(1.6, 1.8, 1.2), Vector3.new(x + 1, topY, front), C.Trim)
end

local function buildRamen(parent: Instance, rng: Random): BasePart
	local x = L.RamenX
	local station, topY = buildStation(parent, "RamenStation", x, 10)
	local front = BACK_Z + 1.6
	local hotWater = PartFactory.box(station, "HotWater", Vector3.new(1.6, 2, 1.4), Vector3.new(x - 2, topY, front), C.Fridge)
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"
	steam.Color = ColorSequence.new(Color3.new(1, 1, 1))
	steam.Transparency = NumberSequence.new(0.7, 1)
	steam.Size = NumberSequence.new(0.4, 1.4)
	steam.Lifetime = NumberRange.new(1.5, 2.5)
	steam.Rate = 4
	steam.Speed = NumberRange.new(0.6, 1)
	steam.EmissionDirection = Enum.NormalId.Top
	steam.Parent = hotWater
	-- A tower of cup noodles
	for level = 0, 2 do
		for i = 0, 2 - level do
			Packaging.cupNoodle(station, Vector3.new(x + 1 + i * 0.85 + level * 0.42, topY + level * 0.96, front), pastel(rng))
		end
	end
	menuBoard(station, x, "HOT RAMEN", { "Miso   4 hearts", "Spicy   4 hearts", "Shoyu   3 hearts" })
	return hotWater
end

local function buildStaffDoor(parent: Instance)
	local door = model(parent, "StaffDoor")
	local x = L.StaffDoorX
	PartFactory.box(door, "Door", Vector3.new(4, 8, 0.3), Vector3.new(x, FLOOR_Y, BACK_Z + 0.15), C.Register)
	PartFactory.box(door, "Knob", Vector3.new(0.3, 0.3, 0.3), Vector3.new(x + 1.4, FLOOR_Y + 3.8, BACK_Z + 0.4), C.CounterTop)
	local sign = PartFactory.box(door, "Sign", Vector3.new(2.6, 0.8, 0.1), Vector3.new(x, FLOOR_Y + 6, BACK_Z + 0.35), C.CounterTop)
	PartFactory.label(sign, Enum.NormalId.Back, "STAFF ONLY", C.SignText)
end

-- The breaker box on the right wall: reset it when the power goes out.
local function buildBreaker(parent: Instance): BasePart
	local at = StoreConfig.Power.BreakerPosition
	local box = model(parent, "Breaker")
	local panel = PartFactory.box(box, "Panel", Vector3.new(0.4, 1.8, 1.3), Vector3.new(at.X, FLOOR_Y + 3.4, at.Z), C.Register)
	PartFactory.box(box, "Lever", Vector3.new(0.3, 0.5, 0.2), Vector3.new(at.X - 0.3, FLOOR_Y + 4.1, at.Z), C.Neon)
	local sign = PartFactory.box(box, "Sign", Vector3.new(0.1, 0.5, 1.6), Vector3.new(at.X - 0.1, FLOOR_Y + 5.5, at.Z), C.CounterTop)
	PartFactory.label(sign, Enum.NormalId.Left, "BREAKER", C.SignText) -- the Left face points into the store (-X)
	return panel
end

export type FixtureParts = {
	Shaker: BasePart,
	HotWater: BasePart,
	Breaker: BasePart,
}

function Fixtures.build(parent: Instance): FixtureParts
	local fixtures = model(parent, "Fixtures")
	local rng = Random.new(2026) -- fixed seed so the store looks the same every run
	local sections = { { "Snacks", "SNACKS" }, { "Sweets", "SWEETS" }, { "Noodles", "NOODLES" } }
	for i, x in L.Shelves.X do
		local section = sections[(i - 1) % #sections + 1]
		buildShelf(fixtures, x, section[1], section[2], rng)
	end
	buildCooler(fixtures, rng)
	buildFreezer(fixtures, 10, 14.5, rng)
	buildFreezer(fixtures, 17, 14.5, rng)
	Packaging.hangingSign(fixtures, Vector3.new(13.5, SIGN_Y, 14.5), 7, "FROZEN TREATS", Color3.fromRGB(150, 200, 255), false)
	local shaker = buildBubbleTea(fixtures, rng)
	local hotWater = buildRamen(fixtures, rng)
	buildStaffDoor(fixtures)
	local breaker = buildBreaker(fixtures)
	return { Shaker = shaker, HotWater = hotWater, Breaker = breaker }
end

return Fixtures
