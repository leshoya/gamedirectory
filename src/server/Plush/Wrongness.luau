--!strict
-- Visual "wrongness" for anomaly plushes. The gory one is plush-style: a torn seam with stuffing
-- bulging out, and (if StoreConfig.Gore.RedThread is on) dangling red threads and a stain.
-- Gore can be switched off entirely with StoreConfig.Gore.Enabled.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Shapes = require(script.Parent.Shapes)

local Wrongness = {}

local STUFFING = Color3.fromRGB(252, 250, 245)
local GASH = Color3.fromRGB(70, 22, 34)
local RED_THREAD = Color3.fromRGB(150, 20, 40)

-- Drains a palette toward grey (the "Wrong Pastel" anomaly).
function Wrongness.grey(colors: PlushSpecies.Palette): PlushSpecies.Palette
	local grey = Color3.fromRGB(165, 160, 168)
	return {
		Body = colors.Body:Lerp(grey, 0.85),
		Belly = colors.Belly:Lerp(grey, 0.6),
		Accent = colors.Accent:Lerp(grey, 0.8),
	}
end

-- A torn seam at `dir` on an oval (the head, usually): a dark gash, ragged stitches,
-- stuffing spilling out, and red thread.
function Wrongness.tornSeam(model: Model, oval: Shapes.Oval, dir: Vector3, rng: Random)
	local gore = StoreConfig.Gore
	if not gore.Enabled then
		return
	end
	local at = Shapes.onSurface(oval, dir, -0.04) * CFrame.Angles(0, 0, math.rad(-30))
	Shapes.blob(model, "Gash", Vector3.new(1.0, 0.3, 0.12), at, GASH, Enum.Material.SmoothPlastic)

	-- Ragged broken stitches along both lips of the tear.
	local thread = if gore.RedThread then RED_THREAD else Color3.fromRGB(110, 90, 110)
	for lip = -1, 1, 2 do
		for i = -2, 2 do
			local stitch = at * CFrame.new(i * 0.2, lip * 0.17, -0.04) * CFrame.Angles(0, 0, math.rad(80 + rng:NextNumber(-25, 25)))
			Shapes.bar(model, "TornStitch", Vector3.new(0.2, 0.04, 0.04), stitch, thread)
		end
	end

	-- Stuffing bulging out of the gash.
	for i = 1, 5 do
		local tuft = at * CFrame.new(rng:NextNumber(-0.4, 0.4), rng:NextNumber(-0.08, 0.08), -rng:NextNumber(0.05, 0.2))
		local s = rng:NextNumber(0.25, 0.42)
		Shapes.blob(model, "Stuffing", Vector3.new(s, s * 0.85, s), tuft, STUFFING)
	end

	if gore.RedThread then
		-- Threads dripping down from the tear, each ending in a little bead.
		for i = 1, 3 do
			local length = rng:NextNumber(0.4, 0.9)
			local top = (at * CFrame.new(-0.3 + i * 0.18, -0.15, -0.02)).Position
			Shapes.bar(model, "Drip", Vector3.new(0.05, length, 0.05), CFrame.new(top - Vector3.new(0, length / 2, 0)), RED_THREAD)
			Shapes.blob(model, "DripBead", Vector3.new(0.12, 0.16, 0.12), CFrame.new(top - Vector3.new(0, length, 0)), RED_THREAD, Enum.Material.SmoothPlastic)
		end
		local stain = Shapes.blob(model, "Stain", Vector3.new(0.9, 0.55, 0.08), Shapes.onSurface(oval, dir + Vector3.new(0.1, -0.3, 0), -0.03), RED_THREAD)
		stain.Transparency = 0.35
	end
end

return Wrongness
