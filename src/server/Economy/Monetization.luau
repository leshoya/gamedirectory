--!strict
-- Game passes and developer products. Ids live in StoreConfig.Monetization; 0 means not set up,
-- and that item is simply skipped. Passes set player attributes ("DoubleTips", "VIP");
-- products are granted in ProcessReceipt once the player's data has loaded.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anomalies = require(ReplicatedStorage.Shared.Anomalies)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Inventory = require(script.Parent.Inventory)
local Rulebook = require(script.Parent.Parent.Progress.Rulebook)
local Awards = require(script.Parent.Parent.Progress.Awards)

local Monetization = {}

local cfg = StoreConfig.Monetization

local function ownsPass(player: Player, passId: number): boolean
	if passId <= 0 then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
	end)
	return ok and owns == true
end

local function checkPasses(player: Player)
	player:SetAttribute("DoubleTips", ownsPass(player, cfg.Passes.DoubleTips))
	player:SetAttribute("VIP", ownsPass(player, cfg.Passes.VIP))
	Awards.check(player)
end

-- What each developer product does.
local GRANTS: { [string]: (Player) -> () } = {
	IdolJacket = function(player)
		Inventory.grant(player, "IdolJacket")
	end,
	StarStick = function(player)
		Inventory.grant(player, "StarStick")
	end,
	SecondChance = function(player)
		player:SetAttribute("SecondChances", ((player:GetAttribute("SecondChances") or 0) :: number) + 1)
	end,
	RulebookHint = function(player)
		local data = PlayerData.get(player)
		if not data then
			return
		end
		for _, anomaly in Anomalies.List do
			if not data.Rulebook[anomaly.Id] then
				Rulebook.unlock(player, anomaly.Id)
				return
			end
		end
	end,
}

local function productName(productId: number): string?
	for name, id in cfg.Products do
		if id > 0 and id == productId then
			return name
		end
	end
	return nil
end

function Monetization.init()
	PlayerData.onLoaded(function(player)
		checkPasses(player)
	end)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _, purchased)
		if purchased then
			checkPasses(player)
		end
	end)
	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		local name = productName(receipt.ProductId)
		if not player or not PlayerData.get(player) or not name then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		GRANTS[name](player)
		PlayerData.save(player)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

return Monetization
