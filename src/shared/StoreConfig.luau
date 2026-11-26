--!strict
-- Tunable numbers and colors for the store. Change values here, not in the builders.
-- The store is centered on the origin: X is width, Z is depth, the door is on the +Z wall.

local StoreConfig = {}

-- Floor top height. Kept above y = 0 so it doesn't z-fight a default Baseplate.
StoreConfig.FloorY = 0.2

StoreConfig.Size = {
	Width = 56,
	Depth = 40,
	WallHeight = 14,
	WallThickness = 1,
	DoorWidth = 8,
	DoorHeight = 9,
	FloorTile = 4, -- Width and Depth should both divide by this
}

-- Where things go inside the store (X across, Z from the back wall at -Depth/2 to the door at +Depth/2).
StoreConfig.Layout = {
	Shelves = { X = { 2, 10, 18 }, Z = -1, Length = 16 }, -- three aisles of two-sided shelves
	Fridge = { Z = -2, Length = 20 }, -- along the right wall
	BubbleTeaX = -16, -- stations against the back wall
	RamenX = 2,
	StaffDoorX = 20,
	ManagerSpot = Vector3.new(20, 0, -15.5), -- Manager Mochi stands in front of the staff door
	ManagerCamera = Vector3.new(13.5, 7.5, -6), -- intro close-up: from the aisle, looking past the shelf end
	WindowBar = { FromX = -25, ToX = -7 }, -- a counter with stools along the front window
	CeilingLights = { X = { -21, -7, 7, 21 }, Z = { -12, -1, 10 } },
	StringLightSpacing = 2.5,
	LightEvery = 4, -- every 4th string light actually lights up the room
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
	Wainscot = Color3.fromRGB(255, 226, 238), -- lower wall panels
	Road = Color3.fromRGB(70, 66, 86),
	Leaf = Color3.fromRGB(150, 210, 160),
	Pot = Color3.fromRGB(255, 205, 170),
	Wood = Color3.fromRGB(235, 205, 175),
}

-- Pastel colors for string lights, bunting, lanterns and capsule toys.
StoreConfig.Pastels = {
	Color3.fromRGB(255, 160, 205),
	Color3.fromRGB(160, 225, 255),
	Color3.fromRGB(255, 225, 140),
	Color3.fromRGB(175, 235, 190),
	Color3.fromRGB(210, 180, 255),
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
	Position = Vector3.new(-14, 0, 6), -- counter center (Y is ignored; it sits on the floor)
	CounterSize = Vector3.new(12, 3.5, 3.5),
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

export type Item = { DisplayName: string, CupColor: Color3, Style: "Cup" | "Bowl", Making: ("Shake" | "Whisk")? }
export type Sound = { Id: number, Volume: number, Speed: number? }

-- Things a worker can carry and a customer can order. Drinks with Making are made in a minigame.
StoreConfig.Items = {
	MilkTea = {
		DisplayName = "milk tea",
		CupColor = Color3.fromRGB(230, 200, 170),
		Style = "Cup",
		Making = "Shake",
	},
	TaroTea = {
		DisplayName = "taro milk tea",
		CupColor = Color3.fromRGB(200, 170, 240),
		Style = "Cup",
		Making = "Shake",
	},
	Matcha = {
		DisplayName = "matcha latte",
		CupColor = Color3.fromRGB(170, 215, 140),
		Style = "Cup",
		Making = "Whisk",
	},
	Ramen = {
		DisplayName = "hot ramen",
		CupColor = Color3.fromRGB(255, 215, 150),
		Style = "Bowl",
	},
} :: { [string]: Item }

-- Drink minigames at the bubble tea bar. Finish faster for a better drink and bigger tips.
StoreConfig.Drinks = {
	PromptDistance = 6,
	Shake = { Target = 24, TimeLimit = 7, PerfectTime = 3.5, GoodTime = 5 }, -- alternating A/D presses
	Whisk = { Target = 6, TimeLimit = 9, PerfectTime = 4.5, GoodTime = 6.5 }, -- full circles
	SpillBelow = 0.5, -- out of time below this much progress: the drink spills
	TurboEffort = 0.7, -- the Turbo Shaker upgrade cuts the work to 70%
	MinTime = 1.2, -- the server ignores drinks "made" faster than this
	QualityTips = { Perfect = 1.5, Good = 1.2, Okay = 1 },
}

-- Hold-to-make stations. MakeTime is how long to hold E (halved by the Turbo Shaker).
StoreConfig.Ramen = {
	PromptDistance = 6,
	MakeTime = 2,
}

-- Plush customers. Positions are on the floor (Y is ignored).
StoreConfig.Customers = {
	SpawnPosition = Vector3.new(0, 0, 28), -- out on the sidewalk
	DoorPosition = Vector3.new(0, 0, 16), -- just inside the door
	OrderSpot = Vector3.new(-12, 0, 9.8), -- customer side of the register
	PlushScale = 1.35, -- how big plushes are; at 1.35 their heads clear the counter
	WalkSpeed = 7, -- studs per second
	HopHeight = 0.35,
	HopRate = 9, -- hops per second while walking
	Patience = 35, -- seconds a customer waits before giving up (+25% with Comfy Mats)
	ReplyTime = 2, -- seconds a reply bubble ("Thank you!") stays up before they leave
	LeaveSlowSpeed = 2.5, -- turned-away anomalies leave slowly, still smiling
	Menu = { "MilkTea", "TaroTea", "Matcha", "Ramen" }, -- what normal customers order
	Payments = { "coins", "a card", "exact change", "shiny coins" }, -- what normal customers pay with
	-- Served anomalies don't leave: they stand in an aisle, watching, until the night ends.
	-- They walk along the front of the aisles at LingerEntryZ, then straight down to their spot.
	LingerEntryZ = 11,
	LingerSpots = { Vector3.new(6, 0, -6), Vector3.new(14, 0, 1), Vector3.new(6, 0, 2), Vector3.new(14, 0, -7) },
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
	TurnAwayBonus = 15, -- turning away an anomaly
	TurnAwayPenalty = 5, -- turning away a real customer
	NightBonus = 25, -- everyone, for surviving a night
	ShiftBonus = 100, -- everyone, for surviving all five
	TipJarBonus = 0.1, -- the Heart Tip Jar upgrade
}

-- The five nights of a shift. More customers and more anomalies each night.
StoreConfig.Nights = {
	{ Customers = 6, AnomalyChance = 0 },
	{ Customers = 8, AnomalyChance = 0.2 },
	{ Customers = 10, AnomalyChance = 0.3 },
	{ Customers = 12, AnomalyChance = 0.4, PowerCuts = true },
	{ Customers = 14, AnomalyChance = 0.5, PowerCuts = true },
}

StoreConfig.Shift = {
	FirstDelay = 8, -- seconds after the server starts before night 1 opens
	OpenTime = 10, -- workers take their stations
	ServiceTime = 180, -- customers arrive
	CloseTime = 12, -- the night's summary card
	BreakTime = 25, -- between shifts (after a win or a loss)
	CustomerGap = 2, -- seconds between one customer leaving and the next arriving
	ExtraCustomersPerPlayer = 1, -- more players, a little busier
	ExtraAnomalyPerPlayer = 0.03,
	OnboardingWait = 150, -- seconds the first night waits for new workers to finish the intro
}

-- Dread fills from mistakes and drains slowly. Full Dread means a blackout.
StoreConfig.Dread = {
	Max = 100,
	DrainPerSecond = 0.4, -- doubled by Brighter Lights
	ServedAnomaly = 35,
	TurnedAwayCustomer = 10,
	CustomerLeft = 8, -- a real customer gave up waiting
	PowerCutPerSecond = 1, -- while the lights are out on nights 4-5
	AfterBlackout = 50, -- where Dread lands if the team resets the breaker in time
}

-- Power cuts (nights 4-5) and the blackout.
StoreConfig.Power = {
	CutEvery = { 35, 60 }, -- seconds between power cuts, random in this range
	ResetHold = 2, -- seconds to hold E at the breaker
	BreakerPosition = Vector3.new(27.4, 0, 14), -- on the right wall near the door
	OutageAmbient = Color3.fromRGB(18, 14, 26),
	BlackoutTime = 20, -- seconds to reset the breaker when Dread fills
	FlickerEvery = 2.5, -- seconds between flickers during the blackout
	Stalkers = 3, -- plushes that creep closer each flicker
	StalkerStep = 3, -- studs closer each flicker
	StalkerSpots = { Vector3.new(-24, 0, -14), Vector3.new(24, 0, -16), Vector3.new(0, 0, 14), Vector3.new(-24, 0, 14) },
}

-- Saved progress. Bump the store name to wipe everyone's data.
StoreConfig.Data = {
	StoreName = "MidnightPlushieMart_v1",
	AutosaveEvery = 120,
}

-- Robux items and badges. 0 means "not set up yet": the shop shows Coming soon, nothing is sold.
StoreConfig.Monetization = {
	Passes = {
		DoubleTips = 0,
		VIP = 0,
	},
	Products = {
		IdolJacket = 0,
		StarStick = 0,
		SecondChance = 0, -- retry a failed blackout once per shift
		RulebookHint = 0, -- reveals one unseen anomaly's tell
	},
	Badges = {
		FirstShift = 0, -- survived all five nights
		RulebookComplete = 0,
	},
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

-- Background sound in the store. The music box slows and drops in pitch as Dread rises,
-- and goes quiet when the power is out. (APM music and a loopable hum, both free on the Creator Store.)
StoreConfig.Ambience = {
	Music = { Id = 1845682836, Volume = 0.22 },
	FridgeHum = { Id = 171186876, Volume = 0.25 },
	MusicSlowdownAtFullDread = 0.35, -- playback speed drops by this much at full Dread
}

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

StoreConfig.SpawnPosition = Vector3.new(0, 0, 13) -- just inside the door
StoreConfig.SignText = "PLUSHIE MART"

return StoreConfig
