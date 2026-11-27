--!strict
-- Background sound. Music shuffles through a playlist of long tracks (cute early on, eerie from
-- EerieFromNight), crossfading with short quiet gaps between them. It slows as Dread rises,
-- while a low drone swells and, near the top, a heartbeat joins in. The cooler hums throughout.
-- Everything but the heartbeat fades out when the power is cut.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local Ambience = {}

local rng = Random.new()

local function sound(id: number, parent: Instance, looped: boolean): Sound
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Looped = looped
	s.Volume = 0
	s.Parent = parent
	return s
end

local function playlistName(): string
	local night = (ReplicatedStorage:GetAttribute("Night") or 1) :: number
	return if night >= StoreConfig.Ambience.EerieFromNight then "Eerie" else "Cute"
end

-- Shuffles a list without putting `avoid` first, so a track never plays twice in a row.
local function shuffled(list: { number }, avoid: number?): { number }
	local copy = table.clone(list)
	for i = #copy, 2, -1 do
		local j = rng:NextInteger(1, i)
		copy[i], copy[j] = copy[j], copy[i]
	end
	if #copy > 1 and copy[1] == avoid then
		copy[1], copy[2] = copy[2], copy[1]
	end
	return copy
end

function Ambience.init()
	local cfg = StoreConfig.Ambience
	local musicLevel = 1 -- 0..1, faded by the track loop; the Heartbeat loop applies volume
	local current: Sound? = nil

	-- Track loop: play a track to the end, crossfade, wait a little, play the next.
	task.spawn(function()
		local queue: { number } = {}
		local queueName = ""
		local last: number? = nil
		while true do
			local name = playlistName()
			if #queue == 0 or name ~= queueName then
				queue, queueName = shuffled(cfg.Playlists[name], last), name
			end
			local id = table.remove(queue, 1) :: number
			last = id
			local track = sound(id, SoundService, false)
			track:Play()
			current = track
			if not track.IsLoaded then
				track.Loaded:Wait()
			end
			-- Play until near the end, or until the night changes playlist.
			while track.IsPlaying and track.TimeLength - track.TimePosition > cfg.CrossfadeTime and playlistName() == queueName do
				task.wait(0.5)
			end
			local fade = Instance.new("NumberValue")
			fade.Value = 1
			fade.Changed:Connect(function(v)
				musicLevel = v
			end)
			local tween = TweenService:Create(fade, TweenInfo.new(cfg.CrossfadeTime), { Value = 0 })
			tween:Play()
			tween.Completed:Wait()
			track:Destroy()
			fade:Destroy()
			current = nil
			task.wait(rng:NextNumber(cfg.QuietGap[1], cfg.QuietGap[2]))
			musicLevel = 1
		end
	end)

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
	local hum = sound(cfg.FridgeHum.Id, humParent, true)
	hum.RollOffMaxDistance = 40
	hum:Play()
	local drone = sound(cfg.Drone.Id, SoundService, true)
	drone:Play()
	local heartbeat = sound(cfg.Heartbeat.Id, SoundService, true)
	heartbeat:Play()

	local fadeIn = 0 -- the track's own fade-in, so new tracks don't start at full volume
	RunService.Heartbeat:Connect(function(dt)
		local dread = ((ReplicatedStorage:GetAttribute("Dread") or 0) :: number) / StoreConfig.Dread.Max
		local powerOut = ReplicatedStorage:GetAttribute("PowerOut") == true
		local ease = math.min(1, dt * 1.5)
		hum.Volume += ((if powerOut then 0 else cfg.FridgeHum.Volume) - hum.Volume) * ease
		drone.Volume += ((if powerOut then cfg.Drone.Volume else cfg.Drone.Volume * dread * dread) - drone.Volume) * ease
		local beat = if powerOut then 1 else math.clamp((dread - cfg.Heartbeat.Above) / (1 - cfg.Heartbeat.Above), 0, 1)
		heartbeat.Volume += (cfg.Heartbeat.Volume * beat - heartbeat.Volume) * ease
		heartbeat.PlaybackSpeed = 1 + 0.4 * beat

		local track = current
		if track then
			fadeIn = math.min(1, fadeIn + dt / cfg.CrossfadeTime)
			local target = if powerOut then 0 else cfg.MusicVolume * musicLevel * fadeIn
			track.Volume += (target - track.Volume) * ease
			track.PlaybackSpeed += ((1 - cfg.MusicSlowdownAtFullDread * dread) - track.PlaybackSpeed) * ease
		else
			fadeIn = 0
		end
	end)
end

return Ambience
