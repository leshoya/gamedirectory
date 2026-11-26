--!strict
-- One item a worker carries in their right hand (a bubble tea cup for now).
-- The player's "Holding" attribute names the item; the cup model is welded to the hand.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PartFactory = require(script.Parent.Parent.Store.PartFactory)

local ATTRIBUTE = "Holding"
local MODEL_NAME = "HeldItem"

local HeldItem = {}

local function findHand(character: Model): BasePart?
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	return if hand and hand:IsA("BasePart") then hand else nil
end

local function weldTo(hand: BasePart, part: BasePart, offset: CFrame)
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanQuery = false
	part.CFrame = hand.CFrame * offset
	local weld = Instance.new("Weld")
	weld.Part0 = hand
	weld.Part1 = part
	weld.C0 = offset
	weld.Parent = part
end

-- A cup with a straw, held upright just below the hand.
local function buildCup(hand: BasePart, color: Color3): Model
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	local upright = CFrame.Angles(0, 0, math.rad(90)) -- cylinders run along X
	local cupOffset = CFrame.new(0, -hand.Size.Y / 2 - 0.25, -0.35)

	local cup = PartFactory.part({
		Name = "Cup",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1.2, 0.8, 0.8),
		CFrame = CFrame.new(),
		Color = color,
	})
	weldTo(hand, cup, cupOffset * upright)
	cup.Parent = model

	local straw = PartFactory.part({
		Name = "Straw",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.9, 0.15, 0.15),
		CFrame = CFrame.new(),
		Color = StoreConfig.Colors.Neon,
	})
	weldTo(hand, straw, cupOffset * CFrame.new(0.1, 0.8, 0) * upright)
	straw.Parent = model
	return model
end

function HeldItem.get(player: Player): string?
	return player:GetAttribute(ATTRIBUTE) :: string?
end

-- Puts an item in the player's hand. Fails if their hands are full or they have no character.
function HeldItem.give(player: Player, itemName: string): boolean
	local item = StoreConfig.Items[itemName]
	local character = player.Character
	local hand = character and findHand(character)
	if not item or not hand or HeldItem.get(player) then
		return false
	end
	buildCup(hand, item.CupColor).Parent = character
	player:SetAttribute(ATTRIBUTE, itemName)
	return true
end

-- Takes the item out of the player's hand and returns its name.
function HeldItem.take(player: Player): string?
	local itemName = HeldItem.get(player)
	local character = player.Character
	local model = character and character:FindFirstChild(MODEL_NAME)
	if model then
		model:Destroy()
	end
	player:SetAttribute(ATTRIBUTE, nil)
	return itemName
end

function HeldItem.init()
	-- A new character starts empty-handed (the old cup went with the old character).
	local function watch(player: Player)
		player.CharacterAdded:Connect(function()
			player:SetAttribute(ATTRIBUTE, nil)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
end

return HeldItem
