--!strict
-- Plays a named sound from StoreConfig.Sounds, in 3D at a position or flat for this player only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

local MAX_LIFETIME = 8 -- seconds; cleanup in case a sound never reports Ended

local Sounds = {}

local function makeSound(name: string): Sound?
	local entry = StoreConfig.Sounds[name]
	if not entry then
		warn("No sound named " .. name)
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. entry.Id
	sound.Volume = entry.Volume
	sound.PlaybackSpeed = entry.Speed or 1
	return sound
end

function Sounds.play(name: string, position: Vector3?)
	local sound = makeSound(name)
	if not sound then
		return
	end
	if position then
		local attachment = Instance.new("Attachment")
		attachment.WorldPosition = position
		attachment.Parent = workspace.Terrain
		sound.RollOffMaxDistance = StoreConfig.Effects.SoundRange
		sound.Parent = attachment
		sound.Ended:Once(function()
			attachment:Destroy()
		end)
		sound:Play()
		Debris:AddItem(attachment, MAX_LIFETIME)
	else
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		sound:Play()
		Debris:AddItem(sound, MAX_LIFETIME)
	end
end

return Sounds
