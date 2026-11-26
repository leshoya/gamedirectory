--!strict
-- Tunable numbers and colors for the store. Change values here, not in the builders.
-- The store is centered on the origin: X is width, Z is depth, the door is on the +Z wall.

local StoreConfig = {}

-- Floor top height. Kept above y = 0 so it doesn't z-fight a default Baseplate.
StoreConfig.FloorY = 0.2

StoreConfig.Size = {
	Width = 40,
	Depth = 30,
	WallHeight = 12,
	WallThickness = 1,
	DoorWidth = 8,
	DoorHeight = 9,
	FloorTile = 5,
}

StoreConfig.Colors = {
	FloorA = Color3.fromRGB(255, 236, 244),
	FloorB = Color3.fromRGB(255, 205, 224),
	Wall = Color3.fromRGB(205, 245, 228), -- mint
	Trim = Color3.fromRGB(214, 196, 255), -- lavender
	Ceiling = Color3.fromRGB(255, 248, 252),
	Window = Color3.fromRGB(200, 230, 255),
	Counter = Color3.fromRGB(255, 182, 210),
	CounterTop = Color3.fromRGB(255, 255, 255),
	Shelf = Color3.fromRGB(255, 244, 214),
	Fridge = Color3.fromRGB(190, 230, 255),
	Register = Color3.fromRGB(180, 160, 230),
	Screen = Color3.fromRGB(45, 35, 70),
	ScreenText = Color3.fromRGB(255, 190, 230),
	Neon = Color3.fromRGB(255, 120, 200),
	Light = Color3.fromRGB(255, 228, 246),
	Sidewalk = Color3.fromRGB(205, 200, 215),
	SignText = Color3.fromRGB(120, 90, 160),
}

StoreConfig.Products = {
	Color3.fromRGB(255, 170, 200),
	Color3.fromRGB(170, 230, 210),
	Color3.fromRGB(200, 180, 255),
	Color3.fromRGB(255, 230, 160),
	Color3.fromRGB(170, 210, 255),
	Color3.fromRGB(255, 200, 170),
}

StoreConfig.Register = {
	Position = Vector3.new(-12, 0, 3), -- counter center (Y is ignored; it sits on the floor)
	CounterSize = Vector3.new(10, 3.5, 3),
	PromptDistance = 7,
	PromptKey = Enum.KeyCode.E,
	ReleaseDistance = 12, -- walk this far from the register and you clock out
	CheckInterval = 0.5, -- seconds between "did the worker walk away?" checks
	IdleText = "OPEN",
}

-- The pastel surfaces are close to white, so keep the light low or everything washes out.
StoreConfig.Lighting = {
	Ambient = Color3.fromRGB(70, 60, 85),
	BloomThreshold = 2, -- only neon (signs, light panels) should glow
	CeilingLightBrightness = 0.5,
	CeilingLightRange = 20,
}

StoreConfig.SpawnPosition = Vector3.new(0, 0, 10) -- just inside the door
StoreConfig.SignText = "PLUSHIE MART"

return StoreConfig
