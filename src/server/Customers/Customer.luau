--!strict
-- One customer's visit: hop in, order at the register, then get served (E), turned away (F),
-- or run out of patience. Anomalies look or act wrong in one learnable way. A served anomaly
-- doesn't leave: it goes and stands in an aisle, watching, until the night ends.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlushSpecies = require(ReplicatedStorage.Shared.PlushSpecies)
local Anomalies = require(ReplicatedStorage.Shared.Anomalies)
local PlushRig = require(script.Parent.Parent.Plush.PlushRig)
local Accessories = require(script.Parent.Parent.Plush.Accessories)
local Blink = require(script.Parent.Parent.Plush.Blink)
local CustomerMover = require(script.Parent.CustomerMover)
local SpeechBubble = require(script.Parent.SpeechBubble)
local HeldItem = require(script.Parent.Parent.Items.HeldItem)
local Upgrades = require(script.Parent.Parent.Economy.Upgrades)
local Feedback = require(script.Parent.Parent.Feedback)
local Outcomes = require(script.Parent.Parent.Shift.Outcomes)

export type Context = {
	Night: number,
	AnomalyChance: number,
	IsOpen: () -> boolean, -- false once the night's service is over
	Linger: Folder, -- where served anomalies wait out the night
}

local PATIENCE_TICK = 0.2

local Customer = {}

local rng = Random.new()

local function pick<T>(list: { T }): T
	return list[rng:NextInteger(1, #list)]
end

local function makePlush(anomaly: Anomalies.Anomaly?): (PlushRig.Plush, boolean)
	local cfg = StoreConfig.Customers
	local sparkle = anomaly == nil and rng:NextNumber() < cfg.SparkleChance
	local options: PlushRig.Options = {
		Sparkle = sparkle,
		Accessory = if rng:NextNumber() < cfg.AccessoryChance then pick(Accessories.Kinds) else nil,
		AccessoryColor = pick(PlushSpecies.AccessoryColors),
	}
	if anomaly and anomaly.Look then
		for key, on in anomaly.Look do
			(options :: any)[key] = on
		end
	end
	return PlushRig.build(pick(cfg.SpeciesPool), options, rng), sparkle
end

local function addPrompt(body: BasePart, objectText: string, action: string, key: Enum.KeyCode, gamepad: Enum.KeyCode): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = objectText
	prompt.ActionText = action
	prompt.KeyboardKeyCode = key
	prompt.GamepadKeyCode = gamepad
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = StoreConfig.Customers.PromptDistance
	prompt.RequiresLineOfSight = false
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	prompt.Parent = body
	return prompt
end

local function freeLingerSpot(folder: Folder): Vector3
	local spots = StoreConfig.Customers.LingerSpots
	return spots[(#folder:GetChildren()) % #spots + 1]
end

function Customer.run(parent: Instance, ctx: Context)
	local cfg = StoreConfig.Customers
	local anomaly: Anomalies.Anomaly? = nil
	if rng:NextNumber() < ctx.AnomalyChance then
		local possible = Anomalies.forNight(ctx.Night)
		if #possible > 0 then
			anomaly = pick(possible)
		end
	end

	local plush, sparkle = makePlush(anomaly)
	local model, head, body = plush.Model, plush.Head, plush.Body
	local voice = if anomaly and anomaly.VoiceSpeed then anomaly.VoiceSpeed else 1

	CustomerMover.place(model, cfg.SpawnPosition, cfg.DoorPosition - cfg.SpawnPosition)
	model.Parent = parent
	if not (anomaly and anomaly.NeverBlinks) then
		Blink.start(model, plush.Eyes, rng)
	end
	local bubble = SpeechBubble.create(head)

	-- Arrive
	Feedback.sound("DoorChime", cfg.DoorPosition)
	if sparkle then
		Feedback.sound("Sparkle", cfg.DoorPosition)
	end
	CustomerMover.walkPath(model, { cfg.DoorPosition, cfg.OrderSpot })
	CustomerMover.face(model, cfg.OrderSpot + Vector3.new(0, 0, -1)) -- face the register

	-- Order: what they want, and how they'll pay
	local order: string? = if anomaly and anomaly.Request then nil else pick(cfg.Menu)
	local request = if order then "One " .. StoreConfig.Items[order].DisplayName .. ", please!" else "Do you have " .. pick((anomaly :: any).Request) .. "?"
	local payment = if anomaly and anomaly.Payment then pick(anomaly.Payment) else pick(cfg.Payments)
	bubble.say(request .. "\nI'll pay with " .. payment .. ".")
	Feedback.sound("Squeak", head.Position, voice)

	local resolved = false
	if anomaly and anomaly.NeverBlinks then
		CustomerMover.stare(model, function()
			return resolved
		end)
	end

	-- Wait to be served or turned away
	local serve = addPrompt(body, plush.DisplayName, "Serve", Enum.KeyCode.E, Enum.KeyCode.ButtonX)
	local turnAway = addPrompt(body, plush.DisplayName, "Sorry, we're closed", Enum.KeyCode.F, Enum.KeyCode.ButtonY)
	local kind: "Served" | "TurnedAway" | "Left" | "Closed" = "Left"
	local by: Player? = nil

	local serveConnection = serve.Triggered:Connect(function(player: Player)
		if by then
			return
		end
		local holding = HeldItem.get(player)
		-- Anomalies take whatever they're handed; real customers want what they ordered.
		if holding and (anomaly or holding == order) then
			HeldItem.take(player)
			kind, by = "Served", player
		else
			local want = if order then "a " .. StoreConfig.Items[order].DisplayName else "something you don't have"
			Feedback.popup("I'd like " .. want .. "!", head.Position + Vector3.new(0, 1.5, 0), StoreConfig.Effects.Bad)
			Feedback.sound("Squeak", head.Position, voice)
		end
	end)
	local turnConnection = turnAway.Triggered:Connect(function(player: Player)
		if not by then
			kind, by = "TurnedAway", player
		end
	end)

	local patience = cfg.Patience * (if Upgrades.has("ComfyMats") then 1.25 else 1)
	local started = os.clock()
	while not by and os.clock() - started < patience and ctx.IsOpen() do
		bubble.setPatience(1 - (os.clock() - started) / patience)
		task.wait(PATIENCE_TICK)
	end
	if not by and not ctx.IsOpen() then
		kind = "Closed"
	end
	resolved = true
	serveConnection:Disconnect()
	turnConnection:Disconnect()
	serve:Destroy()
	turnAway:Destroy()
	bubble.setPatience(nil)

	Outcomes.apply({
		Kind = kind,
		Player = by,
		Anomaly = anomaly and anomaly.Id,
		Waited = os.clock() - started,
		Sparkle = sparkle,
		Position = head.Position,
	})

	-- React and leave
	local exit = { cfg.DoorPosition, cfg.SpawnPosition }
	if kind == "Served" and anomaly then
		bubble.say("Thank you. I think I'll stay.")
		task.wait(cfg.ReplyTime)
		bubble.hide()
		model.Parent = ctx.Linger
		CustomerMover.walkPath(model, { Vector3.new(7.5, 0, 9), freeLingerSpot(ctx.Linger) }, cfg.LeaveSlowSpeed)
		CustomerMover.stare(model, function()
			return false
		end)
		return -- it stays until the night ends
	elseif kind == "Served" then
		bubble.say(if sparkle then "Sparkly thanks!" else "Thank you!")
		Feedback.sound("Register", body.Position)
		Feedback.burst("Hearts", head.Position)
		if sparkle then
			Feedback.burst("Sparkles", head.Position)
		end
		CustomerMover.celebrate(model, cfg.ReplyTime)
	elseif kind == "TurnedAway" then
		bubble.say(if anomaly then "...okay." else "Aww... okay.")
		Feedback.sound(if anomaly then "Squeak" else "Sad", head.Position, voice)
		task.wait(cfg.ReplyTime)
	elseif kind == "Closed" then
		bubble.say("Closing time? Bye!")
		task.wait(cfg.ReplyTime / 2)
	else
		bubble.say("Maybe next time...")
		Feedback.sound("Sad", head.Position)
		task.wait(cfg.ReplyTime)
	end
	bubble.hide()
	-- Turned-away anomalies leave slowly, still smiling.
	CustomerMover.walkPath(model, exit, if anomaly then cfg.LeaveSlowSpeed else nil)
	model:Destroy()
end

return Customer
