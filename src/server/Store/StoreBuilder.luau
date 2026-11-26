--!strict
-- Builds the whole store into workspace.Store, replacing any old copy.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local StoreShell = require(script.Parent.StoreShell)
local Fixtures = require(script.Parent.Fixtures)
local RegisterModel = require(script.Parent.RegisterModel)
local StoreLighting = require(script.Parent.StoreLighting)

export type Store = {
	Model: Model,
	Register: RegisterModel.RegisterParts,
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
	Fixtures.build(store)
	local register = RegisterModel.build(store)
	buildSpawn(store)
	store.Parent = workspace

	StoreLighting.apply()
	return { Model = store, Register = register }
end

return StoreBuilder
