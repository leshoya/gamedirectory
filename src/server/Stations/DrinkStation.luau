--!strict
-- The bubble tea bar: one spot per drink. Pressing E starts a minigame on that player's screen
-- (shake for milk tea and taro, whisk for matcha; see client/DrinkMinigame.luau). While they work,
-- the spot wiggles for everyone. When they finish, the drink goes in their hand with its quality.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Net = require(script.Parent.Parent.Net)
local HeldItem = require(script.Parent.Parent.Items.HeldItem)
local Upgrades = require(script.Parent.Parent.Economy.Upgrades)
local Feedback = require(script.Parent.Parent.Feedback)

local DrinkStation = {}

type Session = { Id: number, Item: string, Started: number, Spot: BasePart, Wiggle: Tween }

local sessions: { [Player]: Session } = {}
local nextId = 0
local QUALITIES = { Perfect = true, Good = true, Okay = true }
local WIGGLE = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

local function finish(player: Player)
	local session = sessions[player]
	if session then
		session.Wiggle:Cancel()
		sessions[player] = nil
	end
end

local function start(player: Player, itemName: string, spot: BasePart, rest: CFrame)
	local item = StoreConfig.Items[itemName]
	local above = spot.Position + Vector3.new(0, 2, 0)
	if sessions[player] then
		return
	end
	if HeldItem.get(player) then
		Feedback.popup("Hands full!", above, StoreConfig.Effects.Bad)
		return
	end
	local making = item.Making :: string
	local settings = (StoreConfig.Drinks :: any)[making]
	local effort = if Upgrades.has("FasterShaker") then StoreConfig.Drinks.TurboEffort else 1

	nextId += 1
	spot.CFrame = rest
	local wiggle = TweenService:Create(spot, WIGGLE, { CFrame = rest * CFrame.Angles(0, 0, math.rad(8)) })
	wiggle:Play()
	sessions[player] = { Id = nextId, Item = itemName, Started = os.clock(), Spot = spot, Wiggle = wiggle }
	wiggle.Completed:Connect(function()
		spot.CFrame = rest
	end)

	-- If the client never reports back (it crashed, or left), free the station anyway.
	local id = nextId
	task.delay(settings.TimeLimit + 10, function()
		local current = sessions[player]
		if current and current.Id == id then
			finish(player)
		end
	end)

	Net.Minigame:FireClient(player, {
		Id = nextId,
		Kind = making,
		Item = itemName,
		Spot = spot,
		Target = math.max(1, math.ceil(settings.Target * effort)),
	})
end

function DrinkStation.init(spots: { [string]: BasePart })
	for itemName, spot in spots do
		local item = StoreConfig.Items[itemName]
		local rest = spot.CFrame
		local attachment = Instance.new("Attachment")
		attachment.Parent = spot
		-- World space: spots are rotated cylinders, so the part's own "up" points sideways.
		attachment.WorldPosition = spot.Position + Vector3.new(0, 1.5, 0)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = "Bubble tea bar"
		prompt.ActionText = (if item.Making == "Whisk" then "Whisk " else "Shake ") .. item.DisplayName
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = StoreConfig.Drinks.PromptDistance
		prompt.RequiresLineOfSight = false
		prompt.Parent = attachment
		prompt.Triggered:Connect(function(player: Player)
			start(player, itemName, spot, rest)
		end)
	end

	Net.MinigameDone.OnServerInvoke = function(player: Player, id: unknown, quality: unknown): boolean
		local session = sessions[player]
		if not session or session.Id ~= id then
			return false
		end
		local elapsed = os.clock() - session.Started
		finish(player)
		local above = session.Spot.Position + Vector3.new(0, 2.5, 0)
		if type(quality) ~= "string" or not QUALITIES[quality] then
			Feedback.popup("Spilled!", above, StoreConfig.Effects.Bad)
			Feedback.sound("Sad", above)
			return false
		end
		if elapsed < StoreConfig.Drinks.MinTime then
			return false -- too fast to be real
		end
		if not HeldItem.give(player, session.Item, quality) then
			return false
		end
		local color = if quality == "Perfect" then StoreConfig.Effects.TipGold elseif quality == "Good" then StoreConfig.Effects.Good else StoreConfig.Colors.Trim
		Feedback.popup(quality .. "!", above, color)
		Feedback.sound("Sparkle", above)
		Feedback.burst("Sparkles", above)
		return true
	end

	Players.PlayerRemoving:Connect(finish)
end

return DrinkStation
