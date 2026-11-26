--!strict
-- Moves a plush along the floor with a little hop, facing where it's going.
-- Plushes are anchored models moved with PivotTo, so they never trip or get pushed around.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local CustomerMover = {}

local FLOOR = StoreConfig.FloorY

local function onFloor(position: Vector3): Vector3
	return Vector3.new(position.X, FLOOR, position.Z)
end

local function flatLook(model: Model): Vector3
	local look = model:GetPivot().LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	return if flat.Magnitude > 0.01 then flat.Unit else Vector3.new(0, 0, -1)
end

function CustomerMover.place(model: Model, position: Vector3, facing: Vector3)
	local at = onFloor(position)
	model:PivotTo(CFrame.lookAt(at, at + Vector3.new(facing.X, 0, facing.Z)))
end

-- Walks in a straight line to the target. Yields until it arrives (or the model is removed).
function CustomerMover.walkTo(model: Model, target: Vector3)
	local cfg = StoreConfig.Customers
	local goal = onFloor(target)
	local position = onFloor(model:GetPivot().Position)
	local elapsed = 0

	while model.Parent do
		local dt = RunService.Heartbeat:Wait()
		elapsed += dt
		local toGoal = goal - position
		local distance = toGoal.Magnitude
		local step = cfg.WalkSpeed * dt
		if distance <= step then
			CustomerMover.place(model, goal, if distance > 0.01 then toGoal else flatLook(model))
			return
		end
		local direction = toGoal.Unit
		position += direction * step
		local hop = math.abs(math.sin(elapsed * cfg.HopRate * math.pi)) * cfg.HopHeight
		local at = position + Vector3.new(0, hop, 0)
		model:PivotTo(CFrame.lookAt(at, at + direction))
	end
end

function CustomerMover.walkPath(model: Model, points: { Vector3 })
	for _, point in points do
		CustomerMover.walkTo(model, point)
	end
end

-- Turns in place to face a point.
function CustomerMover.face(model: Model, point: Vector3)
	local position = model:GetPivot().Position
	CustomerMover.place(model, position, point - position)
end

-- A few happy hops on the spot.
function CustomerMover.celebrate(model: Model, duration: number)
	local cfg = StoreConfig.Customers
	local base = model:GetPivot()
	local elapsed = 0
	while model.Parent and elapsed < duration do
		elapsed += RunService.Heartbeat:Wait()
		local hop = math.abs(math.sin(elapsed * cfg.HopRate * math.pi)) * cfg.HopHeight * 2
		model:PivotTo(base + Vector3.new(0, hop, 0))
	end
	if model.Parent then
		model:PivotTo(base)
	end
end

return CustomerMover
