--!strict
-- A served anomaly doesn't leave. It stands in the aisle, and whenever no worker is looking at it,
-- it steps closer to the nearest one. If it gets close enough: jumpscare, a lot of Dread, and it's gone.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local CustomerMover = require(script.Parent.CustomerMover)
local Feedback = require(script.Parent.Parent.Feedback)
local Dread = require(script.Parent.Parent.Shift.Dread)

local Lingerer = {}

type Target = { Player: Player, Root: BasePart, Distance: number }

local function nearest(at: Vector3): Target?
	local best: Target? = nil
	for _, player in Players:GetPlayers() do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local distance = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(at.X, 0, at.Z)).Magnitude
			if not best or distance < best.Distance then
				best = { Player = player, Root = root, Distance = distance }
			end
		end
	end
	return best
end

-- Is any worker facing it?
local function watched(at: Vector3): boolean
	for _, player in Players:GetPlayers() do
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local toward = Vector3.new(at.X - root.Position.X, 0, at.Z - root.Position.Z)
			local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
			if toward.Magnitude < 1 or (toward.Magnitude > 0 and look.Magnitude > 0 and toward.Unit:Dot(look.Unit) > StoreConfig.Creep.LookingDot) then
				return true
			end
		end
	end
	return false
end

function Lingerer.start(model: Model)
	local cfg = StoreConfig.Creep
	task.spawn(function()
		while model.Parent do
			task.wait(cfg.Every)
			if not model.Parent then
				return
			end
			local at = model:GetPivot().Position
			local target = nearest(at)
			if target then
				local toward = target.Root.Position - at
				local flat = Vector3.new(toward.X, 0, toward.Z)
				if target.Distance <= cfg.CatchDistance then
					-- Got you.
					Feedback.jumpscare(target.Player, model, "Big")
					Dread.add(StoreConfig.Dread.CaughtByLingerer)
					task.wait(StoreConfig.Jumpscare.BigTime)
					model:Destroy()
					return
				elseif not watched(at) and flat.Magnitude > 0 then
					local step = math.min(cfg.Step, target.Distance - cfg.CatchDistance + 0.5)
					CustomerMover.place(model, at + flat.Unit * step, flat)
				else
					CustomerMover.face(model, target.Root.Position)
				end
			end
		end
	end)
end

return Lingerer
