--!strict
-- Cute packaged goods for the shelves: labeled snack boxes with little faces, puffy chip bags,
-- cup noodles, candy jars, drink bottles and cans. All original names, no real brands.
-- Every product sits on `bottom` (the center of its base) and shows its front toward `facing`.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)

local Packaging = {}

Packaging.SnackNames = { "Cloud Chips", "Mochi Bites", "Berry Sticks", "Honey Crisps", "Melon Pops", "Taro Cookies", "Star Puffs", "Peach Gummies", "Sakura Crackers", "Bun Buns" }
Packaging.Faces = { "^_^", "=^.^=", "^o^", "uwu", ">w<", "^-^" }

local WHITE = Color3.new(1, 1, 1)

-- The front of a product faces `facing`: a CFrame whose -Z (LookVector) points that way.
local function frame(bottom: Vector3, height: number, facing: Vector3): CFrame
	local center = bottom + Vector3.new(0, height / 2, 0)
	return CFrame.lookAt(center, center + facing)
end

-- Text on the front face of a box-shaped part.
local function label(part: BasePart, title: string, face: string, color: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0.6
	gui.MaxDistance = 45
	gui.Parent = part
	local band = Instance.new("Frame")
	band.Size = UDim2.fromScale(1, 0.32)
	band.Position = UDim2.fromScale(0, 0.62)
	band.BackgroundColor3 = WHITE
	band.BackgroundTransparency = 0.15
	band.BorderSizePixel = 0
	band.Parent = gui
	local name = Instance.new("TextLabel")
	name.Size = UDim2.fromScale(1, 1)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.FredokaOne
	name.TextScaled = true
	name.TextColor3 = color
	name.Text = title
	name.Parent = band
	local faceLabel = Instance.new("TextLabel")
	faceLabel.Size = UDim2.fromScale(1, 0.5)
	faceLabel.Position = UDim2.fromScale(0, 0.08)
	faceLabel.BackgroundTransparency = 1
	faceLabel.Font = Enum.Font.FredokaOne
	faceLabel.TextScaled = true
	faceLabel.TextColor3 = WHITE
	faceLabel.Text = face
	faceLabel.Parent = gui
end

function Packaging.box(parent: Instance, bottom: Vector3, facing: Vector3, size: Vector3, color: Color3, rng: Random): BasePart
	local part = PartFactory.part({ Name = "SnackBox", Size = size, CFrame = frame(bottom, size.Y, facing), Color = color, Parent = parent })
	label(part, Packaging.SnackNames[rng:NextInteger(1, #Packaging.SnackNames)], Packaging.Faces[rng:NextInteger(1, #Packaging.Faces)], color:Lerp(StoreConfig.Colors.SignText, 0.55))
	return part
end

-- A puffy chip bag: a pillowy oval with crimped seams top and bottom and a white stripe.
function Packaging.bag(parent: Instance, bottom: Vector3, facing: Vector3, color: Color3)
	local cf = frame(bottom, 1.2, facing)
	Shapes.blob(parent, "ChipBag", Vector3.new(0.95, 1.2, 0.5), cf, color, Enum.Material.SmoothPlastic).CanCollide = false
	for side = -1, 1, 2 do
		Shapes.bar(parent, "Crimp", Vector3.new(0.8, 0.08, 0.2), cf * CFrame.new(0, side * 0.55, 0), color:Lerp(WHITE, 0.3))
	end
	Shapes.blob(parent, "BagStripe", Vector3.new(0.7, 0.25, 0.1), cf * CFrame.new(0, 0, -0.22), WHITE, Enum.Material.SmoothPlastic)
end

function Packaging.cupNoodle(parent: Instance, bottom: Vector3, color: Color3)
	PartFactory.cup(parent, "NoodleCup", 0.9, 0.8, bottom, Color3.fromRGB(255, 250, 240))
	PartFactory.cup(parent, "NoodleBand", 0.35, 0.82, bottom + Vector3.new(0, 0.3, 0), color)
	PartFactory.cup(parent, "NoodleLid", 0.06, 0.86, bottom + Vector3.new(0, 0.9, 0), color:Lerp(WHITE, 0.4))
end

-- A glass jar of round candies with a pastel lid.
function Packaging.jar(parent: Instance, bottom: Vector3, rng: Random)
	local glass = PartFactory.cup(parent, "Jar", 1.2, 0.9, bottom, Color3.fromRGB(235, 245, 255))
	glass.Material = Enum.Material.Glass
	glass.Transparency = 0.5
	for i = 1, 6 do
		local candy = StoreConfig.Pastels[rng:NextInteger(1, #StoreConfig.Pastels)]
		local at = bottom + Vector3.new(rng:NextNumber(-0.2, 0.2), 0.2 + (i - 1) * 0.15, rng:NextNumber(-0.2, 0.2))
		Shapes.blob(parent, "Candy", Vector3.one * 0.28, CFrame.new(at), candy, Enum.Material.SmoothPlastic)
	end
	PartFactory.cup(parent, "JarLid", 0.15, 0.95, bottom + Vector3.new(0, 1.2, 0), StoreConfig.Pastels[rng:NextInteger(1, #StoreConfig.Pastels)])
end

function Packaging.bottle(parent: Instance, bottom: Vector3, color: Color3)
	local body = PartFactory.cup(parent, "Bottle", 1.1, 0.45, bottom, color)
	body.Material = Enum.Material.Glass
	body.Transparency = 0.15
	PartFactory.cup(parent, "BottleLabel", 0.4, 0.47, bottom + Vector3.new(0, 0.35, 0), WHITE)
	PartFactory.cup(parent, "BottleNeck", 0.3, 0.22, bottom + Vector3.new(0, 1.1, 0), color)
	PartFactory.cup(parent, "BottleCap", 0.12, 0.25, bottom + Vector3.new(0, 1.4, 0), color:Lerp(Color3.new(0, 0, 0), 0.2))
end

function Packaging.can(parent: Instance, bottom: Vector3, color: Color3)
	local can = PartFactory.cup(parent, "Can", 0.75, 0.42, bottom, color)
	can.Material = Enum.Material.Metal
	PartFactory.cup(parent, "CanTop", 0.04, 0.4, bottom + Vector3.new(0, 0.75, 0), Color3.fromRGB(220, 220, 230)).Material = Enum.Material.Metal
end

-- A two-sided hanging sign (for aisles and sections).
function Packaging.hangingSign(parent: Instance, at: Vector3, width: number, text: string, color: Color3, facesX: boolean)
	local size = if facesX then Vector3.new(0.2, 1.4, width) else Vector3.new(width, 1.4, 0.2)
	local sign = PartFactory.part({ Name = "Sign", Size = size, CFrame = CFrame.new(at), Color = color, Parent = parent })
	local faces = if facesX then { Enum.NormalId.Right, Enum.NormalId.Left } else { Enum.NormalId.Front, Enum.NormalId.Back }
	for _, face in faces do
		PartFactory.label(sign, face, text, WHITE)
	end
	local topY = StoreConfig.FloorY + StoreConfig.Size.WallHeight
	for side = -1, 1, 2 do
		local offset = if facesX then Vector3.new(0, 0, side * width * 0.4) else Vector3.new(side * width * 0.4, 0, 0)
		local wireLength = topY - (at.Y + 0.7)
		PartFactory.part({
			Name = "Wire",
			Size = Vector3.new(0.05, wireLength, 0.05),
			CFrame = CFrame.new(at + offset + Vector3.new(0, 0.7 + wireLength / 2, 0)),
			Color = StoreConfig.Colors.SignText,
			CanCollide = false,
			Parent = parent,
		})
	end
	return sign
end

return Packaging
