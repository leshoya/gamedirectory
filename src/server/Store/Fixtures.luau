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

local METAL = Color3.fromRGB(215, 220, 230)

local function steam(part: BasePart, rate: number)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
	emitter.Transparency = NumberSequence.new(0.7, 1)
	emitter.Size = NumberSequence.new(0.4, 1.4)
	emitter.Lifetime = NumberRange.new(1.5, 2.5)
	emitter.Rate = rate
	emitter.Speed = NumberRange.new(0.6, 1)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = part
end

-- A little name tag on the counter's front edge, facing the worker side (+Z).
local function counterTag(parent: Instance, x: number, topY: number, text: string, color: Color3)
	local tag = PartFactory.box(parent, "Tag", Vector3.new(1.8, 0.45, 0.08), Vector3.new(x, topY - 0.65, BACK_Z + 3.25), color)
	PartFactory.label(tag, Enum.NormalId.Back, text, Color3.new(1, 1, 1))
end

-- A counter against the back wall with cabinet doors, a tiled backsplash and a cup shelf above.
-- Returns the model and the countertop height.
local function buildStation(parent: Instance, name: string, x: number, width: number, rng: Random): (Model, number)
	local station = model(parent, name)
	local depth, height = 3, 3.5
	local z = BACK_Z + depth / 2
	PartFactory.box(station, "Counter", Vector3.new(width, height, depth), Vector3.new(x, FLOOR_Y, z), C.Counter)
	PartFactory.box(station, "Top", Vector3.new(width + 0.4, 0.3, depth + 0.4), Vector3.new(x, FLOOR_Y + height, z), C.CounterTop)
	PartFactory.box(station, "Kick", Vector3.new(width, 0.4, 0.1), Vector3.new(x, FLOOR_Y, BACK_Z + depth + 0.05), C.Trim)
	-- Cabinet doors with little round knobs
	local doors = math.floor(width / 2)
	for i = 0, doors - 1 do
		local dx = x - width / 2 + (i + 0.5) * width / doors
		PartFactory.box(station, "CabinetDoor", Vector3.new(width / doors - 0.2, 2.6, 0.08), Vector3.new(dx, FLOOR_Y + 0.55, BACK_Z + depth + 0.04), C.Counter:Lerp(Color3.new(1, 1, 1), 0.25))
		Shapes.blob(station, "Knob", Vector3.one * 0.2, CFrame.new(dx + (if i % 2 == 0 then 0.55 else -0.55), FLOOR_Y + 2.3, BACK_Z + depth + 0.15), C.CounterTop, Enum.Material.SmoothPlastic)
	end
	-- Tiled backsplash between the counter and the cup shelf
	local tile = 0.8
	for col = 0, math.floor(width / tile) - 1 do
		for row = 0, 1 do
			local color = if (col + row) % 2 == 0 then C.CounterTop else pastel(rng):Lerp(Color3.new(1, 1, 1), 0.5)
			PartFactory.box(station, "Tile", Vector3.new(tile - 0.05, tile - 0.05, 0.06), Vector3.new(x - width / 2 + (col + 0.5) * tile, FLOOR_Y + height + 0.35 + row * tile, BACK_Z + 0.03), color)
		end
	end
	-- Cup shelf with stacks of clear cups
	local shelfY = FLOOR_Y + height + 2.1
	PartFactory.box(station, "CupShelf", Vector3.new(width - 0.5, 0.15, 0.9), Vector3.new(x, shelfY, BACK_Z + 0.55), C.Wood)
	for i = 0, math.floor(width / 1.6) - 1 do
		for k = 0, 1 do
			local cup = PartFactory.cup(station, "StackedCup", 0.3, 0.6, Vector3.new(x - width / 2 + 0.8 + i * 1.6, shelfY + 0.15 + k * 0.22, BACK_Z + 0.5), Color3.fromRGB(240, 248, 255))
			cup.Transparency = 0.35
		end
	end
	return station, FLOOR_Y + height + 0.3
end

-- A steel cocktail shaker: the spot you press E on to shake a drink.
local function shaker(station: Instance, x: number, topY: number, z: number, tea: Color3): BasePart
	local body = PartFactory.cup(station, "Shaker", 1.5, 0.8, Vector3.new(x, topY, z), METAL)
	body.Material = Enum.Material.Metal
	PartFactory.cup(station, "ShakerBand", 0.35, 0.83, Vector3.new(x, topY + 0.4, z), tea)
	Shapes.blob(station, "ShakerCap", Vector3.new(0.75, 0.45, 0.75), CFrame.new(x, topY + 1.55, z), METAL, Enum.Material.Metal)
	return body
end

local function buildBubbleTea(parent: Instance, rng: Random): { [string]: BasePart }
	local x = L.BubbleTeaX
	local station, topY = buildStation(parent, "BubbleTeaBar", x, 12, rng)
	local front = BACK_Z + 1.9
	local back = BACK_Z + 0.7
	local items = StoreConfig.Items

	-- Front row: the three drink spots, a straw cup, and labels on the counter edge
	local milk = shaker(station, x - 4, topY, front, items.MilkTea.CupColor)
	counterTag(station, x - 4, topY, "MILK TEA", C.Neon)
	local taro = shaker(station, x - 1.6, topY, front, items.TaroTea.CupColor)
	counterTag(station, x - 1.6, topY, "TARO", Color3.fromRGB(170, 130, 230))

	local strawCup = PartFactory.cup(station, "StrawCup", 1, 0.7, Vector3.new(x + 0.4, topY, front), C.CounterTop)
	strawCup.Material = Enum.Material.Glass
	strawCup.Transparency = 0.3
	for i = 0, 5 do
		local angle = i / 6 * math.pi * 2
		Shapes.bar(station, "Straw", Vector3.new(0.08, 1.6, 0.08), CFrame.new(x + 0.4 + math.cos(angle) * 0.15, topY + 1.1, front + math.sin(angle) * 0.15) * CFrame.Angles(math.sin(angle) * 0.2, 0, math.cos(angle) * 0.2), pastel(rng))
	end

	-- The matcha set: bowl (the spot), bamboo whisk, tin and scoop
	local bowl = PartFactory.cup(station, "MatchaBowl", 0.6, 1.4, Vector3.new(x + 2.6, topY, front), Color3.fromRGB(235, 225, 210))
	PartFactory.cup(station, "MatchaInBowl", 0.05, 1.2, Vector3.new(x + 2.6, topY + 0.5, front), items.Matcha.CupColor)
	PartFactory.cup(station, "WhiskHandle", 0.9, 0.22, Vector3.new(x + 3.8, topY + 0.6, front - 0.2), C.Wood)
	Shapes.blob(station, "WhiskTines", Vector3.new(0.55, 0.65, 0.55), CFrame.new(x + 3.8, topY + 0.35, front - 0.2), Color3.fromRGB(240, 225, 190))
	PartFactory.cup(station, "MatchaTin", 0.9, 0.6, Vector3.new(x + 4.9, topY, front - 0.1), Color3.fromRGB(120, 170, 110))
	Shapes.bar(station, "MatchaScoop", Vector3.new(0.12, 0.05, 0.9), CFrame.new(x + 4.4, topY + 0.05, front + 0.5) * CFrame.Angles(0, math.rad(30), 0), C.Wood)
	counterTag(station, x + 2.6, topY, "MATCHA", Color3.fromRGB(120, 180, 110))

	-- Back row: syrups, the cup sealer, pearl jars and the tea urn
	for i = 0, 4 do
		Packaging.bottle(station, Vector3.new(x - 5.5 + i * 0.7, topY, back), pastel(rng))
	end
	local sealer = PartFactory.box(station, "CupSealer", Vector3.new(1.3, 1.2, 1.1), Vector3.new(x - 0.5, topY, back + 0.1), C.Register)
	PartFactory.box(station, "SealerLever", Vector3.new(0.15, 0.5, 0.15), Vector3.new(x - 0.5 + 0.5, topY + 1.2, back + 0.4), C.Neon)
	sealer.Material = Enum.Material.SmoothPlastic
	for i = 0, 1 do
		local jar = PartFactory.cup(station, "PearlJar", 1.1, 1, Vector3.new(x + 1.6 + i * 1.2, topY, back), Color3.fromRGB(240, 245, 255))
		jar.Material = Enum.Material.Glass
		jar.Transparency = 0.45
		for k = 1, 5 do
			Shapes.blob(station, "Pearl", Vector3.one * 0.3, CFrame.new(x + 1.6 + i * 1.2 + rng:NextNumber(-0.2, 0.2), topY + 0.15 + k * 0.12, back + rng:NextNumber(-0.2, 0.2)), Color3.fromRGB(70, 45, 50), Enum.Material.SmoothPlastic)
		end
	end
	local urn = PartFactory.cup(station, "TeaUrn", 1.5, 1.4, Vector3.new(x + 4.7, topY, back), METAL)
	urn.Material = Enum.Material.Metal
	PartFactory.cup(station, "UrnLid", 0.15, 1.5, Vector3.new(x + 4.7, topY + 1.5, back), C.Neon)
	Shapes.bar(station, "UrnTap", Vector3.new(0.2, 0.2, 0.5), CFrame.new(x + 4.7, topY + 0.6, back + 0.9), C.CounterTop)
	-- An ice bin tucked in the counter
	PartFactory.box(station, "IceBin", Vector3.new(1.2, 0.4, 1), Vector3.new(x - 5.3, topY - 0.3, front - 0.1), METAL)
	for _ = 1, 5 do
		Shapes.blob(station, "Ice", Vector3.one * 0.3, CFrame.new(x - 5.7 + rng:NextNumber(0, 0.8), topY + 0.15, front - 0.1 + rng:NextNumber(-0.3, 0.3)), Color3.fromRGB(230, 245, 255), Enum.Material.Glass)
	end

	menuBoard(station, x, "BUBBLE TEA", { "Milk Tea - shaken   3 hearts", "Taro - shaken   3 hearts", "Matcha - whisked   4 hearts" })
	return { MilkTea = milk, TaroTea = taro, Matcha = bowl }
end

local function buildRamen(parent: Instance, rng: Random): BasePart
	local x = L.RamenX
	local width = 10
	local station, topY = buildStation(parent, "RamenStation", x, width, rng)
	local front = BACK_Z + 1.9
	local back = BACK_Z + 0.8

	local hotWater = PartFactory.box(station, "HotWater", Vector3.new(1.6, 2, 1.4), Vector3.new(x - 2, topY, front), C.Fridge)
	steam(hotWater, 4)
	counterTag(station, x - 2, topY, "HOT WATER", Color3.fromRGB(120, 170, 230))

	-- A stock pot bubbling on a burner
	PartFactory.box(station, "Burner", Vector3.new(1.8, 0.3, 1.4), Vector3.new(x + 1.5, topY, back + 0.1), Color3.fromRGB(60, 55, 70))
	local pot = PartFactory.cup(station, "StockPot", 1.4, 1.5, Vector3.new(x + 1.5, topY + 0.3, back + 0.1), METAL)
	pot.Material = Enum.Material.Metal
	PartFactory.cup(station, "Broth", 0.05, 1.35, Vector3.new(x + 1.5, topY + 1.62, back + 0.1), Color3.fromRGB(230, 180, 110))
	steam(pot, 6)

	-- Soy and chili bottles, a stack of bowls, and a tower of cup noodles
	Packaging.bottle(station, Vector3.new(x - 4.2, topY, front), Color3.fromRGB(90, 55, 45))
	Packaging.bottle(station, Vector3.new(x - 3.5, topY, front), Color3.fromRGB(230, 70, 60))
	for k = 0, 3 do
		PartFactory.cup(station, "ServingBowl", 0.35, 1.2 - k * 0.04, Vector3.new(x + 0.2, topY + k * 0.33, front), Color3.fromRGB(255, 250, 245))
	end
	for level = 0, 2 do
		for i = 0, 2 - level do
			Packaging.cupNoodle(station, Vector3.new(x + 2.8 + i * 0.85 + level * 0.42, topY + level * 0.96, front), pastel(rng))
		end
	end

	-- Ladles hanging from a rail on the backsplash
	Shapes.bar(station, "LadleRail", Vector3.new(4, 0.12, 0.12), CFrame.new(x - 2.5, topY + 1.7, BACK_Z + 0.2), METAL)
	for i = 0, 2 do
		Shapes.bar(station, "LadleHandle", Vector3.new(0.08, 1.1, 0.08), CFrame.new(x - 3.7 + i * 1.2, topY + 1.15, BACK_Z + 0.25), METAL)
		PartFactory.cup(station, "LadleCup", 0.3, 0.5, Vector3.new(x - 3.7 + i * 1.2, topY + 0.35, BACK_Z + 0.3), METAL).Material = Enum.Material.Metal
	end

	-- A fabric noren banner over the station, one letter per panel
	local letters = { "R", "A", "M", "E", "N" }
	local panelW = width / #letters
	local rodY = FLOOR_Y + S.WallHeight - 1.6
	Shapes.bar(station, "NorenRod", Vector3.new(width + 0.6, 0.15, 0.15), CFrame.new(x, rodY, BACK_Z + 3.4), C.Wood)
	for i, letter in letters do
		local panel = PartFactory.part({
			Name = "Noren",
			Size = Vector3.new(panelW - 0.12, 1.8, 0.06),
			CFrame = CFrame.new(x - width / 2 + (i - 0.5) * panelW, rodY - 0.95, BACK_Z + 3.4),
			Color = Color3.fromRGB(150, 60, 90),
			Material = Enum.Material.Fabric,
			CanCollide = false,
			Parent = station,
		})
		PartFactory.label(panel, Enum.NormalId.Back, letter, C.CounterTop)
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
	DrinkSpots: { [string]: BasePart }, -- item name -> the shaker or bowl to press E on
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
	local drinkSpots = buildBubbleTea(fixtures, rng)
	local hotWater = buildRamen(fixtures, rng)
	buildStaffDoor(fixtures)
	local breaker = buildBreaker(fixtures)
	return { DrinkSpots = drinkSpots, HotWater = hotWater, Breaker = breaker }
end

return Fixtures
