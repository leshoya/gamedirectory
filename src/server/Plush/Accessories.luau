--!strict
-- Little extras a plush can wear: a ribbon bow, a knitted scarf, or a flower.

local Shapes = require(script.Parent.Shapes)

local Accessories = {}

Accessories.Kinds = { "Bow", "Scarf", "Flower" }

local function bow(model: Model, head: Shapes.Oval, color: Color3)
	local at = Shapes.onSurface(head, Vector3.new(0.7, 0.9, -0.3), -0.08)
	for side = -1, 1, 2 do
		local loop = at * CFrame.new(side * 0.3, 0, 0) * CFrame.Angles(0, 0, math.rad(side * -20))
		Shapes.blob(model, "BowLoop", Vector3.new(0.6, 0.42, 0.25), loop, color, Enum.Material.SmoothPlastic)
	end
	Shapes.blob(model, "BowKnot", Vector3.new(0.24, 0.24, 0.26), at, color:Lerp(Color3.new(1, 1, 1), 0.25), Enum.Material.SmoothPlastic)
end

local function scarf(model: Model, body: Shapes.Oval, color: Color3)
	local neck = body.CFrame.Position + Vector3.new(0, body.Size.Y / 2 - 0.15, 0)
	local ring = Shapes.blob(model, "Scarf", Vector3.new(2.05, 0.5, 1.85), CFrame.new(neck), color)
	ring.Material = Enum.Material.Fabric
	local tail = CFrame.new(neck + Vector3.new(0.45, -0.45, -0.85)) * CFrame.Angles(math.rad(-10), 0, math.rad(8))
	Shapes.blob(model, "ScarfTail", Vector3.new(0.42, 0.85, 0.16), tail, color)
	-- knitted stripe
	Shapes.blob(model, "ScarfStripe", Vector3.new(2.08, 0.12, 1.88), CFrame.new(neck), color:Lerp(Color3.new(1, 1, 1), 0.5))
end

local function flower(model: Model, head: Shapes.Oval, color: Color3)
	local at = Shapes.onSurface(head, Vector3.new(-0.75, 0.75, -0.45), -0.03)
	for i = 0, 4 do
		local angle = i * math.pi * 2 / 5
		local petal = at * CFrame.Angles(0, 0, angle) * CFrame.new(0, 0.2, 0)
		Shapes.blob(model, "Petal", Vector3.new(0.22, 0.32, 0.08), petal, color, Enum.Material.SmoothPlastic)
	end
	Shapes.blob(model, "FlowerMiddle", Vector3.new(0.18, 0.18, 0.12), at * CFrame.new(0, 0, -0.03), Color3.fromRGB(255, 225, 120), Enum.Material.SmoothPlastic)
end

function Accessories.build(model: Model, kind: string, head: Shapes.Oval, body: Shapes.Oval, color: Color3)
	if kind == "Bow" then
		bow(model, head, color)
	elseif kind == "Scarf" then
		scarf(model, body, color)
	elseif kind == "Flower" then
		flower(model, head, color)
	end
end

return Accessories
