--!strict
-- One customer's visit: hop in, order a bubble tea at the register, wait to be served
-- (or run out of patience), react, and hop back out.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlushModel = require(script.Parent.PlushModel)
local CustomerMover = require(script.Parent.CustomerMover)
local SpeechBubble = require(script.Parent.SpeechBubble)
local HeldItem = require(script.Parent.Parent.Items.HeldItem)
local Tips = require(script.Parent.Parent.Economy.Tips)
local Feedback = require(script.Parent.Parent.Feedback)

local ORDER = "BubbleTea"
local PATIENCE_TICK = 0.2

local Customer = {}

local rng = Random.new()

local function addServePrompt(body: BasePart, objectText: string): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = objectText
	prompt.ActionText = "Serve"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = StoreConfig.Customers.PromptDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	return prompt
end

-- Waits until someone hands over the order or patience runs out.
-- Returns the player who served, and how long the customer waited.
local function waitToBeServed(prompt: ProximityPrompt, bubble: SpeechBubble.Bubble, head: BasePart): (Player?, number)
	local patience = StoreConfig.Customers.Patience
	local item = StoreConfig.Items[ORDER]
	local servedBy: Player? = nil

	local connection = prompt.Triggered:Connect(function(player: Player)
		if servedBy then
			return
		end
		if HeldItem.get(player) == ORDER then
			HeldItem.take(player)
			servedBy = player
		else
			Feedback.popup("I'd like a " .. item.DisplayName .. "!", head.Position + Vector3.new(0, 1.5, 0), StoreConfig.Effects.Bad)
			Feedback.sound("Squeak", head.Position)
		end
	end)

	local started = os.clock()
	while not servedBy and os.clock() - started < patience do
		bubble.setPatience(1 - (os.clock() - started) / patience)
		task.wait(PATIENCE_TICK)
	end
	connection:Disconnect()
	return servedBy, os.clock() - started
end

function Customer.run(parent: Instance)
	local cfg = StoreConfig.Customers
	local sparkle = rng:NextNumber() < cfg.SparkleChance
	local colors = if sparkle then StoreConfig.Species.SparkleBunny else StoreConfig.Species.Bunny
	local plush = PlushModel.build(colors, sparkle)
	local model, head, body = plush.Model, plush.Head, plush.Body

	CustomerMover.place(model, cfg.SpawnPosition, cfg.DoorPosition - cfg.SpawnPosition)
	model.Parent = parent
	local bubble = SpeechBubble.create(head)

	-- Arrive
	Feedback.sound("DoorChime", cfg.DoorPosition)
	if sparkle then
		Feedback.sound("Sparkle", cfg.DoorPosition)
	end
	CustomerMover.walkPath(model, { cfg.DoorPosition, cfg.OrderSpot })
	CustomerMover.face(model, cfg.OrderSpot + Vector3.new(0, 0, -1)) -- face the register

	-- Order
	bubble.say("One " .. StoreConfig.Items[ORDER].DisplayName .. ", please!")
	Feedback.sound("Squeak", head.Position)
	local prompt = addServePrompt(body, if sparkle then "Sparkle Bunny" else "Bunny")
	local servedBy, waited = waitToBeServed(prompt, bubble, head)
	prompt:Destroy()
	bubble.setPatience(nil)

	-- React
	if servedBy then
		bubble.say(if sparkle then "Sparkly thanks!" else "Thank you!")
		Feedback.sound("Register", body.Position)
		Feedback.burst("Hearts", head.Position)
		if sparkle then
			Feedback.burst("Sparkles", head.Position)
		end
		Tips.forServe(servedBy, waited, if sparkle then cfg.SparkleTipMultiplier else 1, head.Position)
		CustomerMover.celebrate(model, cfg.ReplyTime)
	else
		bubble.say("Maybe next time...")
		Feedback.sound("Sad", head.Position)
		Tips.breakStreak(head.Position)
		task.wait(cfg.ReplyTime)
	end
	bubble.hide()

	-- Leave
	CustomerMover.walkPath(model, { cfg.DoorPosition, cfg.SpawnPosition })
	model:Destroy()
end

return Customer
