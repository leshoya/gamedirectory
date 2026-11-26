--!strict
-- Shelves, the drinks fridge, and placeholder bubble tea and ramen stations.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local S = StoreConfig.Size
local FLOOR_Y = StoreConfig.FloorY
local BACK_Z = -S.Depth / 2

local Fixtures = {}

local function model(parent: Instance, name: string): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

-- Two-sided aisle shelf running along Z, stocked with pastel boxes.
local function buildShelf(parent: Instance, x: number, z: number, length: number, rng: Random)
	local shelf = model(parent, "Shelf")
	PartFactory.box(shelf, "Back", Vector3.new(0.4, 7, length), Vector3.new(x, FLOOR_Y, z), C.Shelf)
	PartFactory.box(shelf, "Base", Vector3.new(3.6, 0.6, length), Vector3.new(x, FLOOR_Y, z), C.Trim)

	local slots = math.floor(length / 1.5)
	for level = 1, 3 do
		local boardY = FLOOR_Y + level * 1.8
		PartFactory.box(shelf, "Board", Vector3.new(3.6, 0.2, length), Vector3.new(x, boardY, z), C.Shelf)
		for side = -1, 1, 2 do
			for i = 0, slots - 1 do
				local pz = z - length / 2 + 0.75 + i * 1.5
				PartFactory.box(
					shelf,
					"Product",
					Vector3.new(1, rng:NextNumber(0.7, 1.3), 1),
					Vector3.new(x + side * 1.1, boardY + 0.2, pz),
					StoreConfig.Products[rng:NextInteger(1, #StoreConfig.Products)]
				)
			end
		end
	end
end

local function buildFridge(parent: Instance)
	local fridge = model(parent, "Fridge")
	local depth, height, length = 3, 8, 16
	local x = S.Width / 2 - depth / 2
	local z = -4
	PartFactory.box(fridge, "Body", Vector3.new(depth, height, length), Vector3.new(x, FLOOR_Y, z), C.Fridge)

	local doors = 4
	local doorLength = length / doors
	for i = 0, doors - 1 do
		local door = PartFactory.box(
			fridge,
			"Door",
			Vector3.new(0.2, height - 1, doorLength - 0.3),
			Vector3.new(x - depth / 2 - 0.1, FLOOR_Y + 0.5, z - length / 2 + doorLength * (i + 0.5)),
			C.Window,
			Enum.Material.Glass
		)
		door.Transparency = 0.3
	end
	local glow = PartFactory.box(
		fridge,
		"Glow",
		Vector3.new(0.3, 0.3, length),
		Vector3.new(x - depth / 2 - 0.15, FLOOR_Y + height - 0.4, z),
		C.Light,
		Enum.Material.Neon
	)
	glow.CanCollide = false
end

-- A counter against the back wall with a sign above it. Returns the model and the countertop height.
local function buildStation(parent: Instance, name: string, signText: string, x: number, width: number): (Model, number)
	local station = model(parent, name)
	local depth, height = 3, 3.5
	local z = BACK_Z + depth / 2
	PartFactory.box(station, "Counter", Vector3.new(width, height, depth), Vector3.new(x, FLOOR_Y, z), C.Counter)
	PartFactory.box(station, "Top", Vector3.new(width + 0.4, 0.3, depth + 0.4), Vector3.new(x, FLOOR_Y + height, z), C.CounterTop)

	local sign = PartFactory.box(station, "Sign", Vector3.new(width - 2, 1.6, 0.2), Vector3.new(x, FLOOR_Y + 7, BACK_Z + 0.1), C.CounterTop)
	-- The Back face points toward +Z, into the store.
	PartFactory.label(sign, Enum.NormalId.Back, signText, C.SignText)
	return station, FLOOR_Y + height + 0.3
end

local function buildBubbleTea(parent: Instance): BasePart
	local x = -13
	local station, topY = buildStation(parent, "BubbleTeaBar", "BUBBLE TEA", x, 10)
	local flavors = {
		Color3.fromRGB(230, 200, 170), -- milk tea
		Color3.fromRGB(200, 170, 240), -- taro
		Color3.fromRGB(190, 230, 170), -- matcha
	}
	for i, color in flavors do
		PartFactory.cup(station, "Cup", 1.4, 0.9, Vector3.new(x - 4.5 + i * 1.5, topY, BACK_Z + 1.5), color)
	end
	return PartFactory.box(station, "Shaker", Vector3.new(1.6, 1.8, 1.2), Vector3.new(x + 3, topY, BACK_Z + 1.5), C.Trim)
end

local function buildRamen(parent: Instance)
	local x = 4
	local station, topY = buildStation(parent, "RamenStation", "HOT RAMEN", x, 8)
	PartFactory.box(station, "HotWater", Vector3.new(1.6, 2, 1.4), Vector3.new(x - 2, topY, BACK_Z + 1.5), C.Fridge)
	for i = 0, 2 do
		PartFactory.cup(station, "RamenCup", 0.8, 1.1, Vector3.new(x + 1.5, topY + i * 0.8, BACK_Z + 1.5), Color3.fromRGB(255, 215, 150))
	end
end

export type FixtureParts = {
	Shaker: BasePart,
}

function Fixtures.build(parent: Instance): FixtureParts
	local fixtures = model(parent, "Fixtures")
	local rng = Random.new(2026) -- fixed seed so the shelves look the same every run
	buildShelf(fixtures, 4, -1, 12, rng)
	buildShelf(fixtures, 11, -1, 12, rng)
	buildFridge(fixtures)
	local shaker = buildBubbleTea(fixtures)
	buildRamen(fixtures)
	return { Shaker = shaker }
end

return Fixtures
