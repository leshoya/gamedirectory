--!strict
-- Full Dread: the lights go out and the store goes quiet. The team has BlackoutTime seconds to
-- reset the breaker while the lights flicker, and each flicker the plushes in the dark stand closer.
-- Reset in time and the shift goes on with Dread at AfterBlackout; fail and the shift is over
-- (unless someone has a Second Chance, which buys one more countdown per shift).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Power = require(script.Parent.Power)
local Dread = require(script.Parent.Dread)
local Feedback = require(script.Parent.Parent.Feedback)
local PlushRig = require(script.Parent.Parent.Plush.PlushRig)
local CustomerMover = require(script.Parent.Parent.Customers.CustomerMover)

local Blackout = {}

local rng = Random.new()
local secondChanceUsed = false

-- Where the plushes first appear in the dark.
local STALKER_SPOTS = StoreConfig.Power.StalkerSpots

local function nearestPlayerRoot(from: Vector3): BasePart?
	local best, bestDistance = nil, math.huge
	for _, player in Players:GetPlayers() do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local d = (root.Position - from).Magnitude
			if d < bestDistance then
				best, bestDistance = root, d
			end
		end
	end
	return best
end

local function spawnStalkers(folder: Folder): { Model }
	local list = {}
	local looks = { { Torn = true, TooWide = true }, { Grey = true, TooWide = true }, { ExtraEar = true, Torn = true } }
	local species = StoreConfig.Customers.SpeciesPool
	for i = 1, StoreConfig.Power.Stalkers do
		local plush = PlushRig.build(species[rng:NextInteger(1, #species)], looks[(i - 1) % #looks + 1], rng)
		local spot = STALKER_SPOTS[(i - 1) % #STALKER_SPOTS + 1]
		CustomerMover.place(plush.Model, spot, Vector3.new(0, 0, 1))
		plush.Model.Parent = folder
		table.insert(list, plush.Model)
	end
	return list
end

-- Each flicker, every stalker steps closer to the nearest worker and turns to face them.
local function creep(stalkers: { Model })
	local step = StoreConfig.Power.StalkerStep
	for _, model in stalkers do
		local at = model:GetPivot().Position
		local target = nearestPlayerRoot(at)
		if target then
			local toward = Vector3.new(target.Position.X - at.X, 0, target.Position.Z - at.Z)
			local distance = toward.Magnitude
			if distance > 3 then
				local move = toward.Unit * math.min(step, distance - 3)
				CustomerMover.place(model, at + move, toward)
			else
				CustomerMover.place(model, at, toward)
			end
		end
	end
end

local function countdown(stalkers: { Model }): boolean
	local cfg = StoreConfig.Power
	local deadline = os.clock() + cfg.BlackoutTime
	ReplicatedStorage:SetAttribute("PhaseEndsAt", workspace:GetServerTimeNow() + cfg.BlackoutTime)
	local nextFlicker = os.clock() + cfg.FlickerEvery
	while os.clock() < deadline do
		if not Power.isOut() then
			return true
		end
		if os.clock() >= nextFlicker then
			nextFlicker = os.clock() + cfg.FlickerEvery
			creep(stalkers)
			task.spawn(Power.flicker, 0.15)
			Feedback.sound("Squeak")
		end
		task.wait(0.1)
	end
	return not Power.isOut()
end

local function useSecondChance(): boolean
	if secondChanceUsed then
		return false
	end
	for _, player in Players:GetPlayers() do
		local chances = (player:GetAttribute("SecondChances") or 0) :: number
		if chances > 0 then
			player:SetAttribute("SecondChances", chances - 1)
			secondChanceUsed = true
			return true
		end
	end
	return false
end

-- A new shift: the Second Chance can be used again.
function Blackout.resetShift()
	secondChanceUsed = false
end

-- Runs the blackout. Returns true if the team got the lights back on.
function Blackout.run(): boolean
	Dread.setPaused(true)
	Power.cut()
	local previousPhase = ReplicatedStorage:GetAttribute("Phase")
	local previousEnd = ReplicatedStorage:GetAttribute("PhaseEndsAt")
	ReplicatedStorage:SetAttribute("Phase", "Blackout")

	local folder = Instance.new("Folder")
	folder.Name = "Stalkers"
	folder.Parent = workspace
	local stalkers = spawnStalkers(folder)

	local survived = countdown(stalkers)
	if not survived and useSecondChance() then
		Feedback.popup("Second Chance!", Vector3.new(0, 8, 0), StoreConfig.Effects.TipGold)
		survived = countdown(stalkers)
	end

	if not survived then
		-- Too late. The closest plush in the dark gets everyone.
		local closest, best = nil, math.huge
		for _, model in stalkers do
			local root = nearestPlayerRoot(model:GetPivot().Position)
			local d = if root then (root.Position - model:GetPivot().Position).Magnitude else math.huge
			if d < best then
				closest, best = model, d
			end
		end
		if closest then
			Feedback.jumpscare(nil, closest, "Big")
			task.wait(StoreConfig.Jumpscare.BigTime)
		end
	end
	folder:Destroy()
	if survived then
		Dread.set(StoreConfig.Dread.AfterBlackout)
		Dread.setPaused(false)
		ReplicatedStorage:SetAttribute("Phase", previousPhase)
		ReplicatedStorage:SetAttribute("PhaseEndsAt", previousEnd)
	end
	return survived
end

return Blackout
