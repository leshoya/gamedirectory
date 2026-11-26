--!strict
-- Manager Mochi: a big plush bear in a tie who stands by the staff door, blinks, sways a little,
-- and stars in the welcome intro (client/Intro.luau). Lives at workspace.Store.Manager.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlushRig = require(script.Parent.Parent.Plush.PlushRig)
local Shapes = require(script.Parent.Parent.Plush.Shapes)
local Blink = require(script.Parent.Parent.Plush.Blink)
local PartFactory = require(script.Parent.PartFactory)

local Manager = {}

-- A necktie and a name tag, placed on the base-size plush (body center at y 1.35, front at -Z).
local function dressUp(model: Model)
	local tie = StoreConfig.Colors.Neon
	Shapes.blob(model, "TieKnot", Vector3.new(0.32, 0.26, 0.2), CFrame.new(0, 2.35, -0.95), tie, Enum.Material.SmoothPlastic)
	Shapes.blob(model, "Tie", Vector3.new(0.38, 1.0, 0.15), CFrame.new(0, 1.75, -1.12) * CFrame.Angles(math.rad(-15), 0, 0), tie, Enum.Material.SmoothPlastic)
	local tag = PartFactory.part({
		Name = "NameTag",
		Size = Vector3.new(0.9, 0.4, 0.05),
		CFrame = CFrame.new(0.55, 1.9, -1.05) * CFrame.Angles(math.rad(-15), 0, 0),
		Color = Color3.new(1, 1, 1),
		CanCollide = false,
		Parent = model,
	})
	PartFactory.label(tag, Enum.NormalId.Front, "MANAGER", StoreConfig.Colors.SignText)
end

function Manager.build(parent: Instance): Model
	local rng = Random.new(3)
	local plush = PlushRig.build("Bear", { Scale = 1 }, rng)
	local model = plush.Model
	model.Name = "Manager"
	dressUp(model)
	model:ScaleTo(1.75)

	local spot = StoreConfig.Layout.ManagerSpot
	local base = CFrame.lookAt(Vector3.new(spot.X, StoreConfig.FloorY, spot.Z), Vector3.new(spot.X, StoreConfig.FloorY, spot.Z + 1))
	model:PivotTo(base)
	model.Parent = parent
	Blink.start(model, plush.Eyes, rng)

	-- A gentle idle sway so the manager feels alive.
	task.spawn(function()
		local t = 0
		while model.Parent do
			t += task.wait(0.1)
			model:PivotTo(base * CFrame.Angles(0, math.sin(t * 0.8) * 0.12, math.sin(t * 1.6) * 0.03))
		end
	end)
	return model
end

return Manager
