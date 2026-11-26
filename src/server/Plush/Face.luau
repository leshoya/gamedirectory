--!strict
-- A plush face: shiny button eyes, blush, a nose, an embroidered mouth, and per-species extras
-- (muzzle, whiskers, eye patch, frog eye bumps). Built on the head oval, facing -Z.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Shapes = require(script.Parent.Shapes)

export type Options = {
	TooWide: boolean?, -- anomaly: a smile stitched far too wide
}

export type Eyes = {
	Eyes: { BasePart },
	Shines: { BasePart },
}

local Face = {}

local WHITE = Color3.new(1, 1, 1)

local function button(model: Model, at: CFrame, eyes: Eyes)
	local eye = Shapes.blob(model, "Eye", Vector3.new(0.42, 0.48, 0.2), at, PlushSpecies.EyeColor, Enum.Material.SmoothPlastic)
	eye.Reflectance = 0.1
	local shine = Shapes.blob(model, "EyeShine", Vector3.new(0.13, 0.13, 0.08), at * CFrame.new(-0.08, 0.11, -0.09), WHITE, Enum.Material.SmoothPlastic)
	table.insert(eyes.Eyes, eye)
	table.insert(eyes.Shines, shine)
end

-- Mouth stitch directions on a host oval, centered at height y0.
local function mouthDirs(kind: string, y0: number, tooWide: boolean): { { Vector3 } }
	if kind == "Cat" and not tooWide then
		-- a little "w": two bumps side by side
		local arcs = {}
		for side = -1, 1, 2 do
			local arc = {}
			for i = 0, 4 do
				local t = i / 4
				local x = side * 0.22 * t
				table.insert(arc, Vector3.new(x, y0 - 0.07 * math.sin(math.pi * t), -1))
			end
			table.insert(arcs, arc)
		end
		return arcs
	end
	local width = if tooWide then 0.95 elseif kind == "Wide" then 0.42 else 0.2
	local depth = if tooWide then 0.18 elseif kind == "Wide" then 0.1 else 0.08
	local steps = if tooWide then 10 else 6
	local arc = {}
	for i = 0, steps do
		local x = -width + 2 * width * i / steps
		table.insert(arc, Vector3.new(x, y0 - depth * (1 - (x / width) ^ 2), -1))
	end
	return { arc }
end

function Face.build(model: Model, head: Shapes.Oval, species: PlushSpecies.Species, colors: PlushSpecies.Palette, options: Options): Eyes
	local eyes: Eyes = { Eyes = {}, Shines = {} }
	local thread = Shapes.shade(colors.Body, 0.75)

	-- Eye patch goes on first so the eye sits on top of it.
	if species.EyePatch then
		Shapes.blob(model, "EyePatch", Vector3.new(0.85, 0.8, 0.12), Shapes.onSurface(head, Vector3.new(-0.42, 0.16, -1), -0.03), colors.Accent)
	end

	-- Eyes
	if species.EyeBumps then
		for side = -1, 1, 2 do
			-- Upright, so the eye on its front faces forward rather than up.
			local spot = Shapes.onSurface(head, Vector3.new(side * 0.5, 1, -0.35), -0.2).Position
			local bump = Shapes.blob(model, "EyeBump", Vector3.new(0.9, 0.85, 0.85), CFrame.new(spot), colors.Body)
			button(model, Shapes.onSurface(Shapes.of(bump), Vector3.new(0, 0.05, -1), -0.04), eyes)
		end
	else
		for side = -1, 1, 2 do
			button(model, Shapes.onSurface(head, Vector3.new(side * 0.42, 0.15, -1), -0.04), eyes)
		end
	end

	-- Blush
	for side = -1, 1, 2 do
		local blush = Shapes.blob(model, "Blush", Vector3.new(0.45, 0.28, 0.08), Shapes.onSurface(head, Vector3.new(side * 0.78, -0.22, -1), -0.02), colors.Accent)
		blush.Transparency = 0.25
	end

	-- Nose and mouth sit on the muzzle if there is one, otherwise on the face.
	local host = head
	local noseY, mouthY = -0.1, -0.32
	local noseColor = colors.Accent
	if species.Muzzle then
		local muzzle = Shapes.blob(model, "Muzzle", Vector3.new(1.15, 0.8, 0.75), Shapes.onSurface(head, Vector3.new(0, -0.38, -1), -0.25), colors.Belly)
		host = Shapes.of(muzzle)
		noseY, mouthY = 0.22, -0.12
		noseColor = PlushSpecies.EyeColor
	end
	Shapes.blob(model, "Nose", Vector3.new(0.3, 0.2, 0.18), Shapes.onSurface(host, Vector3.new(0, noseY, -1), -0.05), noseColor, Enum.Material.SmoothPlastic)

	if options.TooWide then
		-- Stitched across the whole face, cheek to cheek, even past a muzzle.
		for _, arc in mouthDirs(species.Mouth, -0.42, true) do
			Shapes.stitches(model, Shapes.path(head, arc, 0), thread, 0.07)
		end
	end
	if not options.TooWide or species.Muzzle then
		for _, arc in mouthDirs(species.Mouth, mouthY, false) do
			Shapes.stitches(model, Shapes.path(host, arc, 0), thread, 0.06)
		end
	end

	if species.Whiskers then
		local whisker = colors.Body:Lerp(PlushSpecies.EyeColor, 0.45)
		for side = -1, 1, 2 do
			local base = Shapes.onSurface(head, Vector3.new(side * 0.6, -0.22, -1), 0)
			for j = -1, 1, 2 do
				local cf = base * CFrame.new(side * 0.4, j * 0.06, 0) * CFrame.Angles(0, 0, math.rad(j * side * 10))
				Shapes.bar(model, "Whisker", Vector3.new(0.7, 0.04, 0.04), cf, whisker)
			end
		end
	end

	return eyes
end

return Face
