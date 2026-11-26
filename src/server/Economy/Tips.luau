--!strict
-- Tips: saved per player and shown in the player list. The serve streak is shared by the team
-- and published on ReplicatedStorage as the "TeamStreak" attribute so the HUD can show it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Feedback = require(script.Parent.Parent.Feedback)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Upgrades = require(script.Parent.Upgrades)

local Tips = {}

local streak = 0

local function setStreak(value: number)
	streak = value
	ReplicatedStorage:SetAttribute("TeamStreak", value)
end

local function tipsValue(player: Player): IntValue?
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Tips") :: IntValue?
end

local function setupPlayer(player: Player)
	if player:FindFirstChild("leaderstats") then
		return
	end
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local tips = Instance.new("IntValue")
	tips.Name = "Tips"
	tips.Parent = stats
	stats.Parent = player
end

function Tips.init()
	Players.PlayerAdded:Connect(setupPlayer)
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
	PlayerData.onLoaded(function(player, data)
		setupPlayer(player)
		local value = tipsValue(player)
		if value then
			value.Value = data.Tips
		end
	end)
	setStreak(0)
end

-- Adds (or with a negative amount, takes) tips, never going below zero. Returns the change.
function Tips.add(player: Player, amount: number): number
	local data = PlayerData.get(player)
	if not data then
		return 0
	end
	local before = data.Tips
	data.Tips = math.max(0, before + math.floor(amount + 0.5))
	local value = tipsValue(player)
	if value then
		value.Value = data.Tips
	end
	return data.Tips - before
end

-- Spends tips if the player has enough.
function Tips.spend(player: Player, amount: number): boolean
	local data = PlayerData.get(player)
	if not data or data.Tips < amount then
		return false
	end
	Tips.add(player, -amount)
	return true
end

-- Earned tips get the Tip Jar upgrade and the Double Tips pass.
function Tips.earn(player: Player, base: number): number
	local multiplier = 1
	if Upgrades.has("TipJar") then
		multiplier += StoreConfig.Tips.TipJarBonus
	end
	if player:GetAttribute("DoubleTips") then
		multiplier *= 2
	end
	return Tips.add(player, base * multiplier)
end

-- Pays a player for serving a customer and grows the team streak. Returns the amount paid.
function Tips.forServe(player: Player, waited: number, multiplier: number, position: Vector3): number
	local cfg = StoreConfig.Tips
	local fx = StoreConfig.Effects
	local fast = waited <= cfg.FastTime

	local base = cfg.Base + (if fast then cfg.FastBonus else 0)
	local streakBonus = math.min(streak * cfg.StreakStep, cfg.StreakMaxBonus)
	local amount = Tips.earn(player, base * multiplier * (1 + streakBonus))
	setStreak(streak + 1)

	Feedback.popup("+" .. amount .. " tips", position + Vector3.new(0, 1.5, 0), fx.TipGold)
	if fast then
		Feedback.popup("Speedy!", position + Vector3.new(0, 3, 0), fx.Good)
	end
	Feedback.sound("Coin", position)
	return amount
end

-- A mistake: the team streak resets.
function Tips.breakStreak(position: Vector3)
	if streak > 0 then
		Feedback.popup("Streak lost", position + Vector3.new(0, 1.5, 0), StoreConfig.Effects.Bad)
	end
	setStreak(0)
end

return Tips
