--!strict
-- As Dread rises the pastel store drains toward grey, and past halfway the neon sign
-- now and then flickers to a different word.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local WRONG_WORDS = { "PLUSHIE HURT", "STAY", "WE SEE YOU", "DON'T LEAVE", "PLUSHIE MART" }
local CALM_TINT = Color3.fromRGB(255, 246, 252)
local DREAD_TINT = Color3.fromRGB(175, 172, 192)

local DreadEffects = {}

local function signLabel(): TextLabel?
	local store = workspace:FindFirstChild("Store")
	local sign = store and store:FindFirstChild("NeonSign", true)
	local label = sign and sign:FindFirstChild("TextLabel", true)
	return if label and label:IsA("TextLabel") then label else nil
end

function DreadEffects.init()
	local correction = Lighting:WaitForChild("DreadCorrection", 30) :: ColorCorrectionEffect?
	local shown = 0

	RunService.RenderStepped:Connect(function(dt)
		local target = ((ReplicatedStorage:GetAttribute("Dread") or 0) :: number) / StoreConfig.Dread.Max
		shown += (target - shown) * math.min(1, dt * 2) -- ease toward the real value
		if correction then
			correction.Saturation = 0.1 + (-0.9 - 0.1) * shown
			correction.Contrast = 0.2 * shown
			correction.TintColor = CALM_TINT:Lerp(DREAD_TINT, shown)
		end
	end)

	task.spawn(function()
		local rng = Random.new()
		while true do
			task.wait(rng:NextNumber(3, 8))
			local dread = ((ReplicatedStorage:GetAttribute("Dread") or 0) :: number) / StoreConfig.Dread.Max
			local label = signLabel()
			if label and dread > 0.5 then
				local normal = StoreConfig.SignText
				label.Text = WRONG_WORDS[rng:NextInteger(1, #WRONG_WORDS)]
				task.wait(rng:NextNumber(0.2, 0.6))
				label.Text = normal
			end
		end
	end)
end

return DreadEffects
