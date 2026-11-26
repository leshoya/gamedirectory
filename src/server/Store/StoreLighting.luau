--!strict
-- Night-time pastel lighting with soft bloom. DreadCorrection is the hook for the color drain later.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local StoreLighting = {}

local function getOrCreate(className: string, name: string): Instance
	local existing = Lighting:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end
	local effect = Instance.new(className)
	effect.Name = name
	effect.Parent = Lighting
	return effect
end

function StoreLighting.apply()
	Lighting.ClockTime = 0
	Lighting.Brightness = 1
	Lighting.Ambient = StoreConfig.Lighting.Ambient
	Lighting.OutdoorAmbient = Color3.fromRGB(80, 70, 110)

	local bloom = getOrCreate("BloomEffect", "StoreBloom") :: BloomEffect
	bloom.Intensity = 0.6
	bloom.Size = 30
	bloom.Threshold = StoreConfig.Lighting.BloomThreshold

	local correction = getOrCreate("ColorCorrectionEffect", "DreadCorrection") :: ColorCorrectionEffect
	correction.Saturation = 0.1
	correction.TintColor = Color3.fromRGB(255, 246, 252)
end

return StoreLighting
