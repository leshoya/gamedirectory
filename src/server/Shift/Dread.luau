--!strict
-- The Dread meter (0 to Max). Mistakes fill it, it drains slowly, and power cuts push it up.
-- Published as the ReplicatedStorage "Dread" attribute; clients drain the store's colors with it.
-- When it fills, the onFull callback runs once (the blackout) until Dread is set below Max again.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Upgrades = require(script.Parent.Parent.Economy.Upgrades)

local Dread = {}

local value = 0
local paused = false
local fullHandler: (() -> ())? = nil
local powerOut: () -> boolean = function()
	return false
end

local function publish()
	ReplicatedStorage:SetAttribute("Dread", math.floor(value * 10 + 0.5) / 10)
end

function Dread.get(): number
	return value
end

function Dread.set(amount: number)
	value = math.clamp(amount, 0, StoreConfig.Dread.Max)
	publish()
end

function Dread.add(amount: number)
	if paused then
		return
	end
	Dread.set(value + amount)
	if value >= StoreConfig.Dread.Max and fullHandler then
		paused = true -- stays frozen until the blackout is over
		task.spawn(fullHandler)
	end
end

-- Freezes or unfreezes the meter (during the blackout and between shifts).
function Dread.setPaused(isPaused: boolean)
	paused = isPaused
end

function Dread.init(onFull: () -> (), isPowerOut: () -> boolean)
	fullHandler = onFull
	powerOut = isPowerOut
	Dread.set(0)
	task.spawn(function()
		while true do
			task.wait(1)
			if not paused then
				local cfg = StoreConfig.Dread
				if powerOut() then
					Dread.add(cfg.PowerCutPerSecond)
				else
					local drain = cfg.DrainPerSecond * (if Upgrades.has("BrighterLights") then 2 else 1)
					Dread.set(value - drain)
				end
			end
		end
	end)
end

return Dread
