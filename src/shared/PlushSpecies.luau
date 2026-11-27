--!strict
-- The plush cast. Each species is one base rig plus its own ears, tail, face details and colors.
-- To add a species, add an entry here and its name to StoreConfig.Customers.SpeciesPool.

export type Palette = {
	Body: Color3,
	Belly: Color3, -- belly patch, muzzle, tail puff
	Accent: Color3, -- inner ears, paw pads, blush
}

export type Species = {
	DisplayName: string,
	Colors: Palette,
	Ears: "Long" | "Pointy" | "Round" | "Floppy" | "None",
	EarsUseAccent: boolean?, -- whole ear in the accent color (puppy)
	Tail: "Puff" | "Long" | "Nub" | "Wag" | "None",
	Mouth: "Smile" | "Cat" | "Wide" | "Teeth" | "Beak",
	EyeColor: Color3?, -- defaults to PlushSpecies.EyeColor
	Muzzle: boolean?, -- a rounded snout that holds the nose and mouth
	Whiskers: boolean?,
	EyePatch: boolean?, -- a colored patch around one eye
	EyeBumps: boolean?, -- eyes sit on bumps on top of the head (frog)
}

local PlushSpecies = {}

PlushSpecies.EyeColor = Color3.fromRGB(40, 32, 55)

PlushSpecies.List = {
	Bunny = {
		DisplayName = "Bunny",
		Colors = {
			Body = Color3.fromRGB(255, 214, 230),
			Belly = Color3.fromRGB(255, 242, 247),
			Accent = Color3.fromRGB(255, 160, 195),
		},
		Ears = "Long",
		Tail = "Puff",
		Mouth = "Smile",
	},
	Kitten = {
		DisplayName = "Kitten",
		Colors = {
			Body = Color3.fromRGB(255, 222, 186),
			Belly = Color3.fromRGB(255, 246, 232),
			Accent = Color3.fromRGB(255, 165, 170),
		},
		Ears = "Pointy",
		Tail = "Long",
		Mouth = "Cat",
		Whiskers = true,
	},
	Bear = {
		DisplayName = "Bear",
		Colors = {
			Body = Color3.fromRGB(222, 192, 168),
			Belly = Color3.fromRGB(250, 234, 218),
			Accent = Color3.fromRGB(240, 160, 165),
		},
		Ears = "Round",
		Tail = "Nub",
		Mouth = "Smile",
		Muzzle = true,
	},
	Puppy = {
		DisplayName = "Puppy",
		Colors = {
			Body = Color3.fromRGB(248, 244, 238),
			Belly = Color3.fromRGB(255, 255, 255),
			Accent = Color3.fromRGB(196, 176, 232),
		},
		Ears = "Floppy",
		EarsUseAccent = true,
		Tail = "Wag",
		Mouth = "Smile",
		Muzzle = true,
		EyePatch = true,
	},
	Frog = {
		DisplayName = "Frog",
		Colors = {
			Body = Color3.fromRGB(186, 232, 196),
			Belly = Color3.fromRGB(240, 255, 232),
			Accent = Color3.fromRGB(255, 178, 200),
		},
		Ears = "None",
		Tail = "None",
		Mouth = "Wide",
		EyeBumps = true,
	},
	-- Night 3 on: plushes that were never quite meant to be cute.
	Wolf = {
		DisplayName = "Wolf",
		Colors = {
			Body = Color3.fromRGB(150, 148, 168),
			Belly = Color3.fromRGB(215, 210, 225),
			Accent = Color3.fromRGB(120, 95, 150),
		},
		Ears = "Pointy",
		Tail = "Long",
		Mouth = "Teeth",
		Muzzle = true,
		EyeColor = Color3.fromRGB(235, 200, 60),
	},
	Crow = {
		DisplayName = "Crow",
		Colors = {
			Body = Color3.fromRGB(62, 58, 82),
			Belly = Color3.fromRGB(110, 102, 135),
			Accent = Color3.fromRGB(150, 140, 170),
		},
		Ears = "None",
		Tail = "None",
		Mouth = "Beak",
		EyeColor = Color3.fromRGB(230, 50, 70),
	},
} :: { [string]: Species }

-- The rare Sparkle variant of any species wears these colors.
PlushSpecies.SparklePalette = {
	Body = Color3.fromRGB(226, 206, 255),
	Belly = Color3.fromRGB(250, 242, 255),
	Accent = Color3.fromRGB(255, 212, 110),
} :: Palette

-- Ribbon colors for bows and scarves.
PlushSpecies.AccessoryColors = {
	Color3.fromRGB(255, 120, 180),
	Color3.fromRGB(140, 200, 255),
	Color3.fromRGB(255, 200, 90),
	Color3.fromRGB(150, 220, 170),
	Color3.fromRGB(190, 150, 255),
}

return PlushSpecies
