--!strict
-- Hold E at the shaker to make a bubble tea. The shaker wiggles and rattles while you hold,
-- and the cup appears in your hand when it's done.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local HeldItem = require(script.Parent.Parent.Items.HeldItem)
local Feedback = require(script.Parent.Parent.Feedback)

local ITEM = "BubbleTea"
local WIGGLE = TweenInfo.new(0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 5, true)

local BubbleTeaStation = {}

function BubbleTeaStation.init(shaker: BasePart)
	local cfg = StoreConfig.BubbleTea
	local restCFrame = shaker.CFrame
	local above = shaker.Position + Vector3.new(0, shaker.Size.Y / 2 + 0.5, 0)

	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.Parent = shaker

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Shaker"
	prompt.ActionText = "Make bubble tea"
	prompt.HoldDuration = cfg.MakeTime
	prompt.MaxActivationDistance = cfg.PromptDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = attachment

	local wiggle: Tween? = nil
	local function stopWiggle()
		if wiggle then
			wiggle:Cancel()
			wiggle = nil
		end
		shaker.CFrame = restCFrame
	end

	prompt.PromptButtonHoldBegan:Connect(function()
		stopWiggle()
		wiggle = TweenService:Create(shaker, WIGGLE, { CFrame = restCFrame * CFrame.Angles(0, 0, math.rad(12)) })
		wiggle:Play()
		Feedback.sound("Shake", shaker.Position)
	end)
	prompt.PromptButtonHoldEnded:Connect(stopWiggle)

	prompt.Triggered:Connect(function(player: Player)
		stopWiggle()
		if HeldItem.give(player, ITEM) then
			Feedback.sound("Sparkle", shaker.Position)
			Feedback.burst("Sparkles", above)
			Feedback.popup("Bubble tea!", above, StoreConfig.Effects.Good)
		else
			Feedback.popup("Hands full!", above, StoreConfig.Effects.Bad)
		end
	end)
end

return BubbleTeaStation
