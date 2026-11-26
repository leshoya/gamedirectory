--!strict
-- Background sound: a looping music box that slows and drops in pitch as Dread rises (the cute
-- jingle going wrong), and a soft hum from the drinks cooler. Both fade out when the power is cut.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local Ambience = {}

local function loop(id: number, parent: Instance): Sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = parent
	sound:Play()
	return sound
end

function Ambience.init()
	local cfg = StoreConfig.Ambience
	local music = loop(cfg.Music.Id, SoundService)

	-- The hum comes from the cooler, so it's louder near the drinks.
	local store = workspace:WaitForChild("Store")
	local cooler = store:WaitForChild("Fixtures"):WaitForChild("ColdDrinks", 30)
	local humParent: Instance = SoundService
	if cooler then
		local body = cooler:FindFirstChild("Body")
		if body then
			humParent = body
		end
	end
	local hum = loop(cfg.FridgeHum.Id, humParent)
	hum.RollOffMaxDistance = 40

	RunService.Heartbeat:Connect(function(dt)
		local dread = ((ReplicatedStorage:GetAttribute("Dread") or 0) :: number) / StoreConfig.Dread.Max
		local powerOut = ReplicatedStorage:GetAttribute("PowerOut") == true
		local ease = math.min(1, dt * 1.5)
		local musicTarget = if powerOut then 0 else cfg.Music.Volume
		local humTarget = if powerOut then 0 else cfg.FridgeHum.Volume
		music.Volume += (musicTarget - music.Volume) * ease
		hum.Volume += (humTarget - hum.Volume) * ease
		music.PlaybackSpeed += ((1 - cfg.MusicSlowdownAtFullDread * dread) - music.PlaybackSpeed) * ease
	end)
end

return Ambience
