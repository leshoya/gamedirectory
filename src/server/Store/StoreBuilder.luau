--!strict
-- Builds the whole store into workspace.Store, replacing any old copy.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local StoreShell = require(script.Parent.StoreShell)
local Exterior = require(script.Parent.Exterior)
local Fixtures = require(script.Parent.Fixtures)
local Decorations = require(script.Parent.Decorations)
local RegisterModel = require(script.Parent.RegisterModel)
local Manager = require(script.Parent.Manager)
local StoreLighting = require(script.Parent.StoreLighting)

export type Store = {
	Model: Model,
	Register: RegisterModel.RegisterParts,
	Shaker: BasePart,
	HotWater: BasePart,
	Breaker: BasePart,
	Lights: { Instance }, -- everything that goes dark in a power cut
}

local StoreBuilder = {}

local function buildSpawn(parent: Instance)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "WorkerSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(6, 0.2, 6)
	spawn.Position = StoreConfig.SpawnPosition + Vector3.new(0, StoreConfig.FloorY + 0.1, 0)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Duration = 0 -- no spawn forcefield bubble
	local decal = spawn:FindFirstChildOfClass("Decal")
	if decal then
		decal:Destroy()
	end
	spawn.Parent = parent
end

function StoreBuilder.build(): Store
	local old = workspace:FindFirstChild("Store")
	if old then
		old:Destroy()
	end

	local store = Instance.new("Model")
	store.Name = "Store"
	StoreShell.build(store)
	Exterior.build(store)
	local fixtures = Fixtures.build(store)
	Decorations.build(store)
	local register = RegisterModel.build(store)
	buildSpawn(store)
	store.Parent = workspace
	Manager.build(store)

	StoreLighting.apply()
	return {
		Model = store,
		Register = register,
		Shaker = fixtures.Shaker,
		HotWater = fixtures.HotWater,
		Breaker = fixtures.Breaker,
		Lights = {
			store:FindFirstChild("Ceiling") :: Instance,
			store:FindFirstChild("StringLights") :: Instance,
			store:FindFirstChild("Decorations") :: Instance,
			store:FindFirstChild("Fixtures") :: Instance,
		},
	}
end

return StoreBuilder
