--!strict
-- Ears for each species, attached to the top of the head oval.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Shapes = require(script.Parent.Shapes)

local Ears = {}

type EarBuilder = (model: Model, head: Shapes.Oval, side: number, outer: Color3, inner: Color3, rng: Random) -> ()

local function earWithInner(model: Model, base: CFrame, size: Vector3, innerScale: Vector3, outer: Color3, inner: Color3)
	local ear = Shapes.blob(model, "Ear", size, base, outer)
	local innerSize = Vector3.new(size.X * innerScale.X, size.Y * innerScale.Y, 0.1)
	Shapes.blob(model, "EarInner", innerSize, ear.CFrame * CFrame.new(0, -size.Y * 0.04, -size.Z / 2 + 0.03), inner)
end

local BUILDERS: { [string]: EarBuilder } = {
	-- Tall bunny ears; each one leans a little differently.
	Long = function(model, head, side, outer, inner, rng)
		local root = Shapes.onSurface(head, Vector3.new(side * 0.42, 1, 0.05), -0.25).Position
		local lean = math.rad(side * -(6 + rng:NextNumber(0, 10)))
		local base = CFrame.new(root) * CFrame.Angles(math.rad(-8), 0, lean) * CFrame.new(0, 1.05, 0)
		earWithInner(model, base, Vector3.new(0.68, 2.2, 0.4), Vector3.new(0.55, 0.75, 1), outer, inner)
	end,
	-- Triangle kitten ears, tipped outward, with a smaller inner triangle.
	Pointy = function(model, head, side, outer, inner)
		local root = Shapes.onSurface(head, Vector3.new(side * 0.6, 1, -0.05), -0.25).Position
		local base = CFrame.new(root) * CFrame.Angles(0, 0, math.rad(side * -16)) * CFrame.new(0, 0.42, 0)
		Shapes.triangle(model, "Ear", 0.95, 1.05, 0.3, base, outer)
		Shapes.triangle(model, "EarInner", 0.55, 0.65, 0.08, base * CFrame.new(0, -0.12, -0.17), inner)
	end,
	-- Round teddy ears.
	Round = function(model, head, side, outer, inner)
		local root = Shapes.onSurface(head, Vector3.new(side * 0.8, 0.85, 0), -0.15).Position
		local base = CFrame.new(root) * CFrame.new(0, 0.2, 0)
		earWithInner(model, base, Vector3.new(0.85, 0.8, 0.42), Vector3.new(0.55, 0.55, 1), outer, inner)
	end,
	-- Long floppy puppy ears hanging down the sides of the head.
	Floppy = function(model, head, side, outer)
		local root = Shapes.onSurface(head, Vector3.new(side * 1, 0.55, -0.05), -0.12).Position
		local base = CFrame.new(root) * CFrame.Angles(0, 0, math.rad(side * 12)) * CFrame.new(side * 0.12, -0.6, 0)
		Shapes.blob(model, "Ear", Vector3.new(0.55, 1.45, 0.42), base, outer)
	end,
}

-- Builds two ears (three if `extra` is set: an anomaly with one ear too many in the middle).
function Ears.build(model: Model, head: Shapes.Oval, species: PlushSpecies.Species, colors: PlushSpecies.Palette, extra: boolean, rng: Random)
	local builder = BUILDERS[species.Ears]
	if not builder then
		return
	end
	local outer = if species.EarsUseAccent then colors.Accent else colors.Body
	builder(model, head, -1, outer, colors.Accent, rng)
	builder(model, head, 1, outer, colors.Accent, rng)
	if extra then
		builder(model, head, 0.05, outer, colors.Accent, rng)
	end
end

return Ears
