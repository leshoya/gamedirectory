--!strict
-- Makes a plush blink every few seconds until it's removed. (A plush that never blinks
-- is one of the planned anomalies, so blinking is opt-in per plush.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Face = require(script.Parent.Face)

local BLINK_TIME = 0.12
local SQUASH = Vector3.new(1, 0.12, 1)

local Blink = {}

function Blink.start(model: Model, eyes: Face.Eyes, rng: Random)
	local cfg = StoreConfig.Customers
	local openSizes = {}
	for i, eye in eyes.Eyes do
		openSizes[i] = eye.Size
	end
	task.spawn(function()
		while model.Parent do
			task.wait(rng:NextNumber(cfg.BlinkMin, cfg.BlinkMax))
			if not model.Parent then
				break
			end
			for i, eye in eyes.Eyes do
				eye.Size = openSizes[i] * SQUASH
			end
			for _, shine in eyes.Shines do
				shine.Transparency = 1
			end
			task.wait(BLINK_TIME)
			for i, eye in eyes.Eyes do
				eye.Size = openSizes[i]
			end
			for _, shine in eyes.Shines do
				shine.Transparency = 0
			end
		end
	end)
end

return Blink
