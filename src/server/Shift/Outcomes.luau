--!strict
-- Scores how each customer visit ended: tips, Dread, streak, Rulebook pages and the night's stats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Tips = require(script.Parent.Parent.Economy.Tips)
local Dread = require(script.Parent.Dread)
local NightStats = require(script.Parent.NightStats)
local Feedback = require(script.Parent.Parent.Feedback)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Rulebook = require(script.Parent.Parent.Progress.Rulebook)
local Awards = require(script.Parent.Parent.Progress.Awards)

export type Outcome = {
	Kind: "Served" | "TurnedAway" | "Left" | "Closed",
	Player: Player?,
	Anomaly: string?, -- anomaly id, if the customer was one
	Waited: number,
	Sparkle: boolean,
	Quality: string?, -- how well the drink was made: "Perfect", "Good" or "Okay"
	Position: Vector3, -- the customer's head, for popups
}

local Outcomes = {}

function Outcomes.apply(outcome: Outcome)
	local cfg = StoreConfig
	local fx = cfg.Effects
	local player = outcome.Player
	local at = outcome.Position

	if outcome.Kind == "Served" and player then
		if outcome.Anomaly then
			Dread.add(cfg.Dread.ServedAnomaly)
			Tips.breakStreak(at)
			NightStats.add("Mistakes")
			Feedback.popup("That wasn't a real customer...", at + Vector3.new(0, 3, 0), fx.Bad)
		else
			local multiplier = if outcome.Sparkle then cfg.Customers.SparkleTipMultiplier else 1
			local quality = outcome.Quality
			if quality then
				multiplier *= (cfg.Drinks.QualityTips :: any)[quality] or 1
				if quality == "Perfect" then
					Feedback.popup("Perfect drink!", at + Vector3.new(0, 4.5, 0), fx.TipGold)
				end
			end
			local paid = Tips.forServe(player, outcome.Waited, multiplier, at)
			NightStats.add("Served")
			NightStats.add("Tips", paid)
		end
	elseif outcome.Kind == "TurnedAway" and player then
		if outcome.Anomaly then
			local paid = Tips.earn(player, cfg.Tips.TurnAwayBonus)
			NightStats.add("Caught")
			NightStats.add("Tips", paid)
			Feedback.popup("Anomaly spotted! +" .. paid, at + Vector3.new(0, 1.5, 0), fx.TipGold)
			Feedback.sound("Sparkle", at)
			Feedback.burst("Sparkles", at)
			Rulebook.spotted(outcome.Anomaly, at)
			local data = PlayerData.get(player)
			if data then
				data.Stats.Caught += 1
			end
			Awards.check(player)
		else
			local lost = -Tips.add(player, -cfg.Tips.TurnAwayPenalty)
			Dread.add(cfg.Dread.TurnedAwayCustomer)
			Tips.breakStreak(at)
			NightStats.add("Mistakes")
			Feedback.popup("They were a real customer! -" .. lost, at + Vector3.new(0, 1.5, 0), fx.Bad)
		end
	elseif outcome.Kind == "Left" and not outcome.Anomaly then
		Dread.add(cfg.Dread.CustomerLeft)
		Tips.breakStreak(at)
		NightStats.add("Mistakes")
	end
end

return Outcomes
