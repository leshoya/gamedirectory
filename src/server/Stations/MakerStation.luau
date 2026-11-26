--!strict
-- A station where workers hold E to make an item (the bubble tea shaker, the ramen hot water).
-- The machine wiggles and rattles while held, and the item appears in your hand when it's done.
-- The Turbo Shaker upgrade halves the hold time.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local HeldItem = require(script.Parent.Parent.Items.HeldItem)
local Upgrades = require(script.Parent.Parent.Economy.Upgrades)
local Feedback = require(script.Parent.Parent.Feedback)

export type Settings = {
	Item: string, -- key in StoreConfig.Items
	Config: { PromptDistance: number, MakeTime: number },
	ObjectText: string,
	ActionText: string,
}

local WIGGLE = TweenInfo.new(0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 5, true)

local MakerStation = {}

function MakerStation.init(machine: BasePart, settings: Settings)
	local restCFrame = machine.CFrame
	local above = machine.Position + Vector3.new(0, machine.Size.Y / 2 + 0.5, 0)
	local itemName = StoreConfig.Items[settings.Item].DisplayName

	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.Parent = machine

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = settings.ObjectText
	prompt.ActionText = settings.ActionText
	prompt.MaxActivationDistance = settings.Config.PromptDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = attachment

	Upgrades.onChanged(function()
		prompt.HoldDuration = settings.Config.MakeTime * (if Upgrades.has("FasterShaker") then 0.5 else 1)
	end)

	local wiggle: Tween? = nil
	local function stopWiggle()
		if wiggle then
			wiggle:Cancel()
			wiggle = nil
		end
		machine.CFrame = restCFrame
	end

	prompt.PromptButtonHoldBegan:Connect(function()
		stopWiggle()
		wiggle = TweenService:Create(machine, WIGGLE, { CFrame = restCFrame * CFrame.Angles(0, 0, math.rad(12)) })
		;(wiggle :: Tween):Play()
		Feedback.sound("Shake", machine.Position)
	end)
	prompt.PromptButtonHoldEnded:Connect(stopWiggle)

	prompt.Triggered:Connect(function(player: Player)
		stopWiggle()
		if HeldItem.give(player, settings.Item) then
			Feedback.sound("Sparkle", machine.Position)
			Feedback.burst("Sparkles", above)
			Feedback.popup(itemName:sub(1, 1):upper() .. itemName:sub(2) .. "!", above, StoreConfig.Effects.Good)
		else
			Feedback.popup("Hands full!", above, StoreConfig.Effects.Bad)
		end
	end)
end

return MakerStation
