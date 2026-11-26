--!strict
-- The register counter: counter, cash register with a screen, a stand spot and the prompt.
-- Customers come from the door side (+Z); the worker stands behind it (-Z).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartFactory = require(script.Parent.PartFactory)
local Packaging = require(script.Parent.Packaging)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local C = StoreConfig.Colors
local FLOOR_Y = StoreConfig.FloorY

export type RegisterParts = {
	Model: Model,
	Prompt: ProximityPrompt,
	Screen: TextLabel,
	StandSpot: BasePart,
}

local RegisterModel = {}

function RegisterModel.build(parent: Instance): RegisterParts
	local cfg = StoreConfig.Register
	local size = cfg.CounterSize
	local base = Vector3.new(cfg.Position.X, FLOOR_Y, cfg.Position.Z)

	local model = Instance.new("Model")
	model.Name = "Register"
	model.Parent = parent

	local counter = PartFactory.box(model, "Counter", size, base, C.Counter)
	local topY = FLOOR_Y + size.Y
	PartFactory.box(model, "Countertop", Vector3.new(size.X + 0.4, 0.3, size.Z + 0.4), Vector3.new(base.X, topY, base.Z), C.CounterTop)

	-- Candy jars and a heart tip jar on the customer side of the counter
	local rng = Random.new(9)
	local counterTop = topY + 0.3
	for i = 0, 1 do
		Packaging.jar(model, Vector3.new(base.X - 5 + i * 1.2, counterTop, base.Z + 0.6), rng)
	end
	local tipJar = PartFactory.cup(model, "TipJar", 1.3, 1.1, Vector3.new(base.X - 2.4, counterTop, base.Z + 0.6), C.Window)
	tipJar.Material = Enum.Material.Glass
	tipJar.Transparency = 0.4
	local heart = PartFactory.part({ Name = "TipHeart", Size = Vector3.new(0.9, 0.9, 0.05), CFrame = CFrame.new(base.X - 2.4, counterTop + 0.65, base.Z + 1.2), Transparency = 1, CanCollide = false, Parent = model })
	PartFactory.label(heart, Enum.NormalId.Back, "TIPS", C.Neon)

	-- Cash register
	local machineBottom = Vector3.new(base.X + 2, topY + 0.3, base.Z)
	local machine = PartFactory.box(model, "Machine", Vector3.new(2.2, 0.8, 1.6), machineBottom, C.Register)
	local screenPart = PartFactory.part({
		Name = "Screen",
		Size = Vector3.new(1.8, 1.1, 0.15),
		-- Front face points at the worker (-Z); tilt the top back so it faces up a little.
		CFrame = CFrame.new(machineBottom + Vector3.new(0, 1.4, 0.3)) * CFrame.Angles(math.rad(15), 0, 0),
		Color = C.Screen,
		Parent = model,
	})
	local screen = PartFactory.label(screenPart, Enum.NormalId.Front, cfg.IdleText, C.ScreenText)

	-- Where the worker stands
	local standSpot = PartFactory.box(
		model,
		"StandSpot",
		Vector3.new(4, 0.05, 3),
		Vector3.new(machineBottom.X, FLOOR_Y, base.Z - size.Z / 2 - 1.8),
		C.Trim
	)
	standSpot.CanCollide = false

	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.Position = Vector3.new(0, 0.2, -0.9) -- worker side of the machine
	attachment.Parent = machine

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Register"
	prompt.ActionText = "Clock in"
	prompt.KeyboardKeyCode = cfg.PromptKey
	prompt.MaxActivationDistance = cfg.PromptDistance
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.Parent = attachment

	model.PrimaryPart = counter
	return {
		Model = model,
		Prompt = prompt,
		Screen = screen,
		StandSpot = standSpot,
	}
end

return RegisterModel
