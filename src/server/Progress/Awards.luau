--!strict
-- Earned titles and badges. Call Awards.check(player) after anything that might earn one.

local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anomalies = require(ReplicatedStorage.Shared.Anomalies)
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Rulebook = require(script.Parent.Rulebook)
local Feedback = require(script.Parent.Parent.Feedback)
local Inventory = require(script.Parent.Parent.Economy.Inventory)

local Awards = {}

local CONDITIONS: { [string]: (Player, PlayerData.Data) -> boolean } = {
	Caught10 = function(_, data)
		return data.Stats.Caught >= 10
	end,
	ShiftWon = function(_, data)
		return data.Stats.ShiftsWon >= 1
	end,
	Nights25 = function(_, data)
		return data.Stats.Nights >= 25
	end,
	RulebookFull = function(player)
		return Rulebook.count(player) >= #Anomalies.List
	end,
	VipPass = function(player)
		return player:GetAttribute("VIP") == true
	end,
}

function Awards.badge(player: Player, name: string)
	local id = StoreConfig.Monetization.Badges[name]
	if id and id > 0 then
		task.spawn(function()
			local ok, err = pcall(function()
				BadgeService:AwardBadge(player.UserId, id)
			end)
			if not ok then
				warn("Badge " .. name .. " failed: " .. tostring(err))
			end
		end)
	end
end

function Awards.check(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	for _, item in Catalog.Items do
		local condition = item.Earned and CONDITIONS[item.Earned]
		if condition and not data.Owned[item.Id] and condition(player, data) then
			Inventory.grant(player, item.Id)
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if root then
				Feedback.popup("New title: " .. item.Name .. "!", root.Position + Vector3.new(0, 4, 0), StoreConfig.Effects.TipGold)
			end
		end
	end
	if data.Stats.ShiftsWon >= 1 then
		Awards.badge(player, "FirstShift")
	end
	if Rulebook.count(player) >= #Anomalies.List then
		Awards.badge(player, "RulebookComplete")
	end
end

return Awards
