--!strict
-- Tips: each player's total shows in the player list. The serve streak is shared by the team
-- and published on ReplicatedStorage as the "TeamStreak" attribute so the HUD can show it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Feedback = require(script.Parent.Parent.Feedback)

local Tips = {}

local streak = 0

local function setStreak(value: number)
	streak = value
	ReplicatedStorage:SetAttribute("TeamStreak", value)
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
	setStreak(0)
end

function Tips.add(player: Player, amount: number)
	local stats = player:FindFirstChild("leaderstats")
	local tips = stats and stats:FindFirstChild("Tips") :: IntValue?
	if tips then
		tips.Value += amount
	end
end

-- Pays a player for serving a customer and grows the team streak. Returns the amount paid.
function Tips.forServe(player: Player, waited: number, multiplier: number, position: Vector3): number
	local cfg = StoreConfig.Tips
	local fx = StoreConfig.Effects
	local fast = waited <= cfg.FastTime

	local amount = cfg.Base + (if fast then cfg.FastBonus else 0)
	local streakBonus = math.min(streak * cfg.StreakStep, cfg.StreakMaxBonus)
	amount = math.floor(amount * multiplier * (1 + streakBonus) + 0.5)

	Tips.add(player, amount)
	setStreak(streak + 1)

	Feedback.popup("+" .. amount .. " tips", position + Vector3.new(0, 1.5, 0), fx.TipGold)
	if fast then
		Feedback.popup("Speedy!", position + Vector3.new(0, 3, 0), fx.Good)
	end
	Feedback.sound("Coin", position)
	return amount
end

-- A customer left unhappy: the team streak resets.
function Tips.breakStreak(position: Vector3)
	if streak > 0 then
		Feedback.popup("Streak lost", position + Vector3.new(0, 1.5, 0), StoreConfig.Effects.Bad)
	end
	setStreak(0)
end

return Tips
