--!strict
-- The cute summary card after each night, and the end-of-shift card: a pastel sunrise if the
-- team made it, a slow fade to black if the lights went out. Both offer an Invite button.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)

local C = StoreConfig.Colors
local FX = StoreConfig.Effects

local ResultsCard = {}

local function invite()
	local player = Players.LocalPlayer
	local ok, canInvite = pcall(function()
		return SocialService:CanSendGameInviteAsync(player)
	end)
	if ok and canInvite then
		pcall(function()
			SocialService:PromptGameInvite(player)
		end)
	end
end

local function row(card: Frame, y: number, name: string, value: string)
	Ui.label(card, name, UDim2.new(0.6, -20, 0, 26), UDim2.fromOffset(24, y), C.SignText, Enum.TextXAlignment.Left)
	Ui.label(card, value, UDim2.new(0.4, -24, 0, 26), UDim2.new(0.6, 0, 0, y), C.Neon, Enum.TextXAlignment.Right)
end

function ResultsCard.init()
	local gui = Ui.screen("Results", 5)
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShiftEvent") :: RemoteEvent

	local black = Instance.new("Frame")
	black.Size = UDim2.fromScale(1, 1)
	black.BackgroundColor3 = Color3.new(0, 0, 0)
	black.BackgroundTransparency = 1
	black.Parent = gui

	local current: Frame? = nil
	local function clear()
		if current then
			current:Destroy()
			current = nil
		end
	end

	local function show(card: Frame, seconds: number)
		clear()
		current = card
		Ui.popIn(card)
		task.delay(seconds, function()
			if current == card then
				clear()
			end
		end)
	end

	remote.OnClientEvent:Connect(function(event: any)
		if event.Type == "NightSummary" then
			local s = event.Stats
			local card = Ui.panel(gui, "NightCard", UDim2.fromOffset(340, 230), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0.5))
			Ui.label(card, ("Night %d complete!"):format(s.Night), UDim2.new(1, -40, 0, 40), UDim2.fromOffset(20, 16), C.Neon)
			row(card, 70, "Customers served", tostring(s.Served))
			row(card, 100, "Anomalies spotted", tostring(s.Caught))
			row(card, 130, "Mistakes", tostring(s.Mistakes))
			row(card, 160, "Team tips", "+" .. tostring(s.Tips))
			Ui.label(card, if event.Last then "Last night done..." else "Next night soon", UDim2.new(1, -40, 0, 22), UDim2.fromOffset(20, 196), C.Trim:Lerp(C.SignText, 0.4))
			show(card, StoreConfig.Shift.CloseTime - 1)
		elseif event.Type == "ShiftOver" then
			local won = event.Won == true
			if not won then
				TweenService:Create(black, TweenInfo.new(2.5), { BackgroundTransparency = 0.15 }):Play()
				task.wait(2.5)
			end
			local card = Ui.panel(gui, "ShiftCard", UDim2.fromOffset(380, 230), UDim2.fromScale(0.5, 0.45), Vector2.new(0.5, 0.5))
			if won then
				card.BackgroundColor3 = Color3.fromRGB(255, 244, 230)
				Ui.label(card, "Sunrise! You survived!", UDim2.new(1, -40, 0, 42), UDim2.fromOffset(20, 18), C.Neon)
				Ui.label(card, ("All five nights done. +%d tips each!"):format(StoreConfig.Tips.ShiftBonus), UDim2.new(1, -40, 0, 26), UDim2.fromOffset(20, 70), C.SignText)
			else
				Ui.label(card, "The lights went out...", UDim2.new(1, -40, 0, 42), UDim2.fromOffset(20, 18), C.SignText)
				Ui.label(card, ("You made it to night %d."):format(event.Night), UDim2.new(1, -40, 0, 26), UDim2.fromOffset(20, 70), C.Trim:Lerp(C.SignText, 0.4))
			end
			Ui.label(card, "A new shift starts soon.", UDim2.new(1, -40, 0, 22), UDim2.fromOffset(20, 110), C.Trim:Lerp(C.SignText, 0.4))
			Ui.button(card, "Invite friends", UDim2.fromOffset(200, 44), UDim2.new(0.5, -100, 1, -64), FX.TipGold, invite)
			show(card, StoreConfig.Shift.BreakTime - 3)
			task.delay(StoreConfig.Shift.BreakTime - 3, function()
				TweenService:Create(black, TweenInfo.new(1.5), { BackgroundTransparency = 1 }):Play()
			end)
		end
	end)
end

return ResultsCard
