--!strict
-- Tails, attached to the back of the body oval (+Z is the back).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Shapes = require(script.Parent.Shapes)

local Tails = {}

function Tails.build(model: Model, body: Shapes.Oval, kind: string, colors: PlushSpecies.Palette)
	local back = Shapes.onSurface(body, Vector3.new(0, -0.25, 1), -0.1)
	if kind == "Puff" then
		Shapes.blob(model, "Tail", Vector3.new(0.8, 0.75, 0.7), back, colors.Belly)
	elseif kind == "Nub" then
		Shapes.blob(model, "Tail", Vector3.new(0.5, 0.48, 0.45), back, colors.Body)
	elseif kind == "Wag" then
		local cf = CFrame.new(back.Position) * CFrame.Angles(math.rad(-40), 0, 0) * CFrame.new(0, 0.4, 0.1)
		Shapes.blob(model, "Tail", Vector3.new(0.38, 1.0, 0.38), cf, colors.Body)
	elseif kind == "Long" then
		-- A curling kitten tail: a chain of shrinking ovals that sweeps up.
		local position = back.Position
		for i = 1, 5 do
			local t = i / 5
			position += Vector3.new(0.12 * math.sin(t * 3), 0.32, 0.28 * (1 - t))
			local size = 0.46 - 0.05 * i
			Shapes.blob(model, "Tail", Vector3.new(size, 0.55, size), CFrame.new(position), if i == 5 then colors.Belly else colors.Body)
		end
	end
end

return Tails
