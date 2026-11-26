--!strict
-- The sticker Rulebook: the first time the team turns away an anomaly, everyone present gets
-- its page. Pages are saved and published as the player's "Rulebook" attribute (a comma list).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anomalies = require(ReplicatedStorage.Shared.Anomalies)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Feedback = require(script.Parent.Parent.Feedback)

local Rulebook = {}

local function publish(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local ids = {}
	for _, anomaly in Anomalies.List do
		if data.Rulebook[anomaly.Id] then
			table.insert(ids, anomaly.Id)
		end
	end
	player:SetAttribute("Rulebook", table.concat(ids, ","))
end

function Rulebook.count(player: Player): number
	local data = PlayerData.get(player)
	local n = 0
	if data then
		for _ in data.Rulebook do
			n += 1
		end
	end
	return n
end

-- Unlocks a page for one player. Returns true if it was new.
function Rulebook.unlock(player: Player, id: string): boolean
	local data = PlayerData.get(player)
	local anomaly = Anomalies.get(id)
	if not data or not anomaly or data.Rulebook[id] then
		return false
	end
	data.Rulebook[id] = true
	publish(player)
	return true
end

-- The team spotted an anomaly: everyone in the server gets the page.
function Rulebook.spotted(id: string, position: Vector3)
	local anyNew = false
	for _, player in Players:GetPlayers() do
		if Rulebook.unlock(player, id) then
			anyNew = true
		end
	end
	local anomaly = Anomalies.get(id)
	if anyNew and anomaly then
		Feedback.popup("New Rulebook page: " .. anomaly.Name, position + Vector3.new(0, 4.5, 0), StoreConfig.Effects.TipGold)
		Feedback.sound("Sparkle")
	end
end

function Rulebook.init()
	PlayerData.onLoaded(function(player)
		publish(player)
	end)
end

return Rulebook
