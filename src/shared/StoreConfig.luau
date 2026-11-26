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

export type Item = { DisplayName: string, CupColor: Color3 }
export type Sound = { Id: number, Volume: number, Speed: number? }

-- Things a worker can carry and a customer can order.
StoreConfig.Items = {
	BubbleTea = {
		DisplayName = "bubble tea",
		CupColor = Color3.fromRGB(230, 200, 170), -- milk tea
	},
} :: { [string]: Item }

StoreConfig.BubbleTea = {
	PromptDistance = 6,
	MakeTime = 1, -- seconds to hold E at the shaker
}

-- Plush customers. Positions are on the floor (Y is ignored).
StoreConfig.Customers = {
	SpawnPosition = Vector3.new(0, 0, 24), -- out on the sidewalk
	DoorPosition = Vector3.new(0, 0, 11), -- just inside the door
	OrderSpot = Vector3.new(-10, 0, 7.2), -- customer side of the register
	WalkSpeed = 7, -- studs per second
	HopHeight = 0.35,
	HopRate = 9, -- hops per second while walking
	Patience = 60, -- seconds a customer waits before giving up
	FirstDelay = 3, -- seconds after the server starts before the first customer
	SpawnDelay = 6, -- seconds between one customer leaving and the next arriving
	ReplyTime = 2, -- seconds a reply bubble ("Thank you!") stays up before they leave
	PromptDistance = 7,
	BubbleMaxDistance = 60,
	SparkleChance = 0.1, -- chance a customer is a rare Sparkle plush
	SparkleTipMultiplier = 3,
	SpeciesPool = { "Bunny", "Kitten", "Bear", "Puppy", "Frog" }, -- see Shared.PlushSpecies
	AccessoryChance = 0.6, -- chance a customer wears a bow, scarf or flower
	BlinkMin = 2.5, -- seconds between blinks
	BlinkMax = 5,
}

-- Anomaly plushes can be torn open. Enabled = false removes the tears entirely;
-- RedThread = false keeps the stuffing but drops the red threads and stain.
-- Blood-like content affects the game's maturity label in Roblox's content questionnaire.
StoreConfig.Gore = {
	Enabled = true,
	RedThread = true,
}

-- Tips for serving. A streak is shared by the whole team and breaks when a customer leaves unserved.
StoreConfig.Tips = {
	Base = 10,
	FastTime = 12, -- serve within this many seconds of the order for the speed bonus
	FastBonus = 5,
	StreakStep = 0.1, -- each customer served in a row adds +10% to tips
	StreakMaxBonus = 1, -- capped at +100%
}

-- Sound effects, by name. Ids are free Creator Store audio that loaded in Studio.
StoreConfig.Sounds = {
	DoorChime = { Id = 9125492239, Volume = 0.35 },
	Squeak = { Id = 9120222115, Volume = 0.6 },
	Shake = { Id = 9116797024, Volume = 0.4, Speed = 1.3 },
	Coin = { Id = 1169806635, Volume = 0.5 },
	Register = { Id = 134810204798705, Volume = 0.5 },
	Sad = { Id = 1836360707, Volume = 0.5 },
	Sparkle = { Id = 2609981431, Volume = 0.5 },
} :: { [string]: Sound }

-- Client-side visual effects.
StoreConfig.Effects = {
	HeartTexture = "rbxassetid://241778280", -- white heart, tinted per burst
	SparkleTexture = "rbxasset://textures/particles/sparkles_main.dds",
	PopupRise = 3, -- studs a "+12" popup floats up
	PopupTime = 1.2, -- seconds it takes to float and fade
	SoundRange = 80, -- how far away 3D sounds can be heard
	TipGold = Color3.fromRGB(255, 200, 70),
	Good = Color3.fromRGB(120, 220, 170),
	Bad = Color3.fromRGB(255, 120, 150),
}

StoreConfig.SpawnPosition = Vector3.new(0, 0, 10) -- just inside the door
StoreConfig.SignText = "PLUSHIE MART"

return StoreConfig
