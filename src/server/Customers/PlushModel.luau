--!strict
-- Builds a plush bunny from simple felt parts: round body and head, tall ears, button eyes.
-- The model's pivot is the center of its feet, and it faces -Z (its LookVector).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PartFactory = require(script.Parent.Parent.Store.PartFactory)

export type Colors = { Body: Color3, Inner: Color3, Eyes: Color3 }

export type Plush = {
	Model: Model,
	Body: BasePart,
	Head: BasePart,
}

local PlushModel = {}

local WHITE = Color3.new(1, 1, 1)

local function piece(
	model: Model,
	name: string,
	shape: Enum.PartType,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local part = PartFactory.part({
		Name = name,
		Shape = shape,
		Size = size,
		CFrame = cframe,
		Color = color,
		Material = material or Enum.Material.Fabric,
		CanCollide = false,
		Parent = model,
	})
	part.CanQuery = name == "Body" -- the serve prompt lives on the body
	part.CastShadow = true
	return part
end

local function ball(model: Model, name: string, diameter: number, position: Vector3, color: Color3, material: Enum.Material?): Part
	return piece(model, name, Enum.PartType.Ball, Vector3.one * diameter, CFrame.new(position), color, material)
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

function PlushModel.build(colors: Colors, sparkle: boolean): Plush
	local model = Instance.new("Model")
	model.Name = if sparkle then "SparkleBunny" else "Bunny"

	local root = piece(model, "Root", Enum.PartType.Block, Vector3.new(2, 0.1, 2), CFrame.new(), WHITE)
	root.Transparency = 1
	model.PrimaryPart = root

	local belly = colors.Body:Lerp(WHITE, 0.55)
	local body = ball(model, "Body", 2.4, Vector3.new(0, 1.4, 0), colors.Body)
	ball(model, "Belly", 1.5, Vector3.new(0, 1.3, -0.55), belly)
	ball(model, "FootL", 0.8, Vector3.new(-0.55, 0.4, -0.6), colors.Body)
	ball(model, "FootR", 0.8, Vector3.new(0.55, 0.4, -0.6), colors.Body)
	ball(model, "Tail", 0.7, Vector3.new(0, 1.2, 1.25), belly)

	local head = ball(model, "Head", 2.3, Vector3.new(0, 3.2, 0), colors.Body)
	ball(model, "EyeL", 0.32, Vector3.new(-0.42, 3.35, -1.05), colors.Eyes, Enum.Material.SmoothPlastic)
	ball(model, "EyeR", 0.32, Vector3.new(0.42, 3.35, -1.05), colors.Eyes, Enum.Material.SmoothPlastic)
	ball(model, "Nose", 0.22, Vector3.new(0, 3.05, -1.13), colors.Inner)
	local cheekL = ball(model, "CheekL", 0.35, Vector3.new(-0.75, 3.0, -0.9), colors.Inner)
	local cheekR = ball(model, "CheekR", 0.35, Vector3.new(0.75, 3.0, -0.9), colors.Inner)
	cheekL.Transparency = 0.3
	cheekR.Transparency = 0.3

	for side = -1, 1, 2 do
		local tilt = CFrame.Angles(0, 0, math.rad(-10 * side))
		local name = if side < 0 then "L" else "R"
		piece(model, "Ear" .. name, Enum.PartType.Block, Vector3.new(0.55, 1.9, 0.35), CFrame.new(0.5 * side, 4.9, 0.1) * tilt, colors.Body)
		piece(model, "EarInner" .. name, Enum.PartType.Block, Vector3.new(0.3, 1.4, 0.1), CFrame.new(0.5 * side, 4.85, -0.1) * tilt, colors.Inner)
	end

	if sparkle then
		addSparkle(head)
	end
	return { Model = model, Body = body, Head = head }
end

return PlushModel
