--!strict
-- The base plush rig shared by every species: an oval body with a stitched belly patch, stubby arms
-- with paw pads, feet with pads, and a big head with a seam over the top. Species add ears, tail and
-- face details; options add accessories, the Sparkle variant, and anomaly wrongness.
-- The model's pivot is the center of its feet, and it faces -Z (its LookVector).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Shapes = require(script.Parent.Shapes)
local Face = require(script.Parent.Face)
local Ears = require(script.Parent.Ears)
local Tails = require(script.Parent.Tails)
local Accessories = require(script.Parent.Accessories)
local Wrongness = require(script.Parent.Wrongness)

export type Options = {
	Sparkle: boolean?,
	Accessory: string?, -- one of Accessories.Kinds
	AccessoryColor: Color3?,
	-- Anomaly wrongness
	ExtraEar: boolean?,
	TooWide: boolean?,
	Grey: boolean?,
	Torn: boolean?,
}

export type Plush = {
	Model: Model,
	Body: BasePart,
	Head: BasePart,
	Eyes: Face.Eyes,
	DisplayName: string,
}

local PlushRig = {}

local BODY_SIZE = Vector3.new(2.4, 2.35, 2.1)
local BODY_CENTER = Vector3.new(0, 1.35, 0)
local HEAD_SIZE = Vector3.new(2.65, 2.3, 2.4)
local HEAD_CENTER = Vector3.new(0, 3.3, 0)

local function buildBody(model: Model, colors: PlushSpecies.Palette): BasePart
	local seam = Shapes.shade(colors.Body, 0.3)
	local body = Shapes.blob(model, "Body", BODY_SIZE, CFrame.new(BODY_CENTER), colors.Body)
	local oval = Shapes.of(body)

	-- Belly patch with a running stitch around its edge
	Shapes.blob(model, "Belly", Vector3.new(1.55, 1.6, 0.35), Shapes.onSurface(oval, Vector3.new(0, -0.12, -1), -0.12), colors.Belly)
	local edge = {}
	for i = 0, 16 do
		local angle = i / 16 * math.pi * 2
		table.insert(edge, Vector3.new(math.cos(angle) * 0.62, -0.12 + math.sin(angle) * 0.66, -1))
	end
	Shapes.stitches(model, Shapes.path(oval, edge, 0.02), seam)

	-- Arms hang down and out from the shoulders, with a paw pad on the front of each.
	for side = -1, 1, 2 do
		local arm = CFrame.new(side * 1.12, 1.65, -0.25) * CFrame.Angles(math.rad(-10), 0, math.rad(side * 28))
		Shapes.blob(model, "Arm", Vector3.new(0.72, 1.3, 0.72), arm, colors.Body)
		Shapes.blob(model, "PawPad", Vector3.new(0.38, 0.34, 0.1), arm * CFrame.new(0, -0.42, -0.33), colors.Accent)
	end

	-- Feet stick out in front, with oval pads on their soles.
	for side = -1, 1, 2 do
		Shapes.blob(model, "Foot", Vector3.new(0.95, 0.62, 1.25), CFrame.new(side * 0.6, 0.31, -0.35), colors.Body)
		local pad = CFrame.lookAt(Vector3.new(side * 0.6, 0.31, -0.97), Vector3.new(side * 0.6, 0.31, -2))
		Shapes.blob(model, "FootPad", Vector3.new(0.5, 0.4, 0.08), pad, colors.Accent)
	end
	return body
end

local function buildHead(model: Model, colors: PlushSpecies.Palette): BasePart
	local head = Shapes.blob(model, "Head", HEAD_SIZE, CFrame.new(HEAD_CENTER), colors.Body)
	-- A seam running from the forehead over the top to the back
	local dirs = {}
	for i = 0, 10 do
		local t = math.rad(35 + i * 12)
		table.insert(dirs, Vector3.new(0, math.sin(t), -math.cos(t)))
	end
	Shapes.stitches(model, Shapes.path(Shapes.of(head), dirs, 0.01), Shapes.shade(colors.Body, 0.3))
	return head
end

local function addSparkle(head: BasePart)
	local fx = StoreConfig.Effects
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Sparkle"
	emitter.Texture = fx.SparkleTexture
	emitter.Color = ColorSequence.new(fx.TipGold, Color3.fromRGB(255, 190, 240))
	emitter.LightEmission = 1
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Lifetime = NumberRange.new(0.8, 1.4)
	emitter.Rate = 10
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = head

	local glow = Instance.new("PointLight")
	glow.Color = fx.TipGold
	glow.Brightness = 0.6
	glow.Range = 8
	glow.Parent = head
end

function PlushRig.build(speciesName: string, options: Options, rng: Random): Plush
	local species = PlushSpecies.List[speciesName]
	assert(species, "Unknown plush species: " .. speciesName)
	local colors = if options.Sparkle then PlushSpecies.SparklePalette else species.Colors
	if options.Grey then
		colors = Wrongness.grey(colors)
	end

	local model = Instance.new("Model")
	model.Name = (if options.Sparkle then "Sparkle" else "") .. speciesName

	-- Invisible root at the feet: the model's pivot
	local root = Shapes.bar(model, "Root", Vector3.new(2, 0.1, 2), CFrame.new(), colors.Body)
	root.Transparency = 1
	model.PrimaryPart = root

	local body = buildBody(model, colors)
	local head = buildHead(model, colors)
	local headOval, bodyOval = Shapes.of(head), Shapes.of(body)

	local eyes = Face.build(model, headOval, species, colors, { TooWide = options.TooWide })
	Ears.build(model, headOval, species, colors, options.ExtraEar == true, rng)
	Tails.build(model, bodyOval, species.Tail, colors)
	if options.Accessory then
		Accessories.build(model, options.Accessory, headOval, bodyOval, options.AccessoryColor or colors.Accent)
	end
	if options.Torn then
		-- The forehead seam splits open above one eye.
		Wrongness.tornSeam(model, headOval, Vector3.new(0.5, 0.62, -0.75), rng)
	end
	if options.Sparkle then
		addSparkle(head)
	end

	return {
		Model = model,
		Body = body,
		Head = head,
		Eyes = eyes,
		DisplayName = (if options.Sparkle then "Sparkle " else "") .. species.DisplayName,
	}
end

return PlushRig
