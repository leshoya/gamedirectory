--!strict
-- Remembers who has seen Manager Mochi's welcome. Published as the player's "SeenIntro"
-- attribute; the client plays the intro (client/Intro.luau) when it's false.

local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Net = require(script.Parent.Parent.Net)

local Intro = {}

function Intro.init()
	PlayerData.onLoaded(function(player, data)
		player:SetAttribute("SeenIntro", data.Flags.SeenIntro == true)
	end)
	Net.IntroDone.OnServerEvent:Connect(function(player)
		local data = PlayerData.get(player)
		if data then
			data.Flags.SeenIntro = true
			player:SetAttribute("SeenIntro", true)
		end
	end)
end

return Intro
