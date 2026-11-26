--!strict
-- Handles the Shop remote: ("Buy", itemId) spends Tips, ("Equip", itemId) wears or takes off an item.
-- Robux items are bought through MarketplaceService on the client and granted by Monetization.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local Net = require(script.Parent.Parent.Net)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Tips = require(script.Parent.Tips)
local Inventory = require(script.Parent.Inventory)
local Upgrades = require(script.Parent.Upgrades)
local Cosmetics = require(script.Parent.Parent.Cosmetics.Cosmetics)

local Shop = {}

export type Reply = { Ok: boolean, Message: string }

local function buy(player: Player, item: Catalog.Item): Reply
	if Inventory.owns(player, item.Id) then
		return { Ok = false, Message = "You already have this." }
	end
	if item.Earned or item.Price == nil then
		return { Ok = false, Message = "This one can't be bought with tips." }
	end
	if not Tips.spend(player, item.Price) then
		return { Ok = false, Message = "Not enough tips yet." }
	end
	Inventory.grant(player, item.Id)
	if item.Kind == "Upgrade" then
		Upgrades.refresh()
	end
	return { Ok = true, Message = "Got it: " .. item.Name .. "!" }
end

local function equip(player: Player, item: Catalog.Item): Reply
	local data = PlayerData.get(player)
	if not data or not Inventory.owns(player, item.Id) or item.Kind == "Upgrade" then
		return { Ok = false, Message = "You don't have this yet." }
	end
	if data.Equipped[item.Kind] == item.Id and item.Kind ~= "Title" then
		data.Equipped[item.Kind] = nil -- tap again to take it off
	else
		data.Equipped[item.Kind] = item.Id
	end
	Inventory.publish(player)
	Cosmetics.apply(player)
	return { Ok = true, Message = "" }
end

function Shop.init()
	Net.Shop.OnServerInvoke = function(player: Player, action: unknown, id: unknown): Reply
		if type(action) ~= "string" or type(id) ~= "string" then
			return { Ok = false, Message = "Bad request." }
		end
		local item = Catalog.get(id)
		if not item or not PlayerData.get(player) then
			return { Ok = false, Message = "Try again in a moment." }
		end
		if action == "Buy" then
			return buy(player, item)
		elseif action == "Equip" then
			return equip(player, item)
		end
		return { Ok = false, Message = "Bad request." }
	end
end

return Shop
