--!strict
-- What a player owns and has equipped, published as player attributes for the shop UI:
--   "Owned" = comma list of item ids, "Equipped_Outfit" / "Equipped_Lightstick" / "Equipped_Title" = item id.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)

local Inventory = {}

local KINDS = { "Outfit", "Lightstick", "Title" }

function Inventory.publish(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local owned = {}
	for _, item in Catalog.Items do
		if data.Owned[item.Id] then
			table.insert(owned, item.Id)
		end
	end
	player:SetAttribute("Owned", table.concat(owned, ","))
	for _, kind in KINDS do
		player:SetAttribute("Equipped_" .. kind, data.Equipped[kind])
	end
end

function Inventory.owns(player: Player, id: string): boolean
	local data = PlayerData.get(player)
	return data ~= nil and data.Owned[id] == true
end

function Inventory.grant(player: Player, id: string)
	local data = PlayerData.get(player)
	if data then
		data.Owned[id] = true
		Inventory.publish(player)
	end
end

function Inventory.init()
	PlayerData.onLoaded(function(player)
		Inventory.publish(player)
	end)
end

return Inventory
