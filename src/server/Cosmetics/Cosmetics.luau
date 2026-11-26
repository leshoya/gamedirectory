--!strict
-- Puts a player's equipped looks on their character: an apron, bunny-ear headband or idol jacket,
-- a glowing lightstick in the left hand, and their title floating above their head.
-- Everything lives in a "Cosmetics" folder in the character and is rebuilt on each change.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Shapes = require(script.Parent.Parent.Plush.Shapes)

local Cosmetics = {}

local function find(character: Model, names: { string }): BasePart?
	for _, name in names do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function weld(base: BasePart, part: BasePart, offset: CFrame)
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CFrame = base.CFrame * offset
	local w = Instance.new("Weld")
	w.Part0 = base
	w.Part1 = part
	w.C0 = offset
	w.Parent = part
end

local function attachBlob(folder: Folder, base: BasePart, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): BasePart
	local part = Shapes.blob(folder, name, size, CFrame.new(), color, material)
	weld(base, part, offset)
	return part
end

local function attachBar(folder: Folder, base: BasePart, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?): BasePart
	local part = Shapes.bar(folder, name, size, CFrame.new(), color, material)
	weld(base, part, offset)
	return part
end

local function apron(folder: Folder, torso: BasePart, color: Color3)
	local front = -torso.Size.Z / 2 - 0.06
	attachBar(folder, torso, "Apron", Vector3.new(torso.Size.X * 0.8, torso.Size.Y * 0.85, 0.1), CFrame.new(0, -torso.Size.Y * 0.12, front), color, Enum.Material.Fabric)
	attachBlob(folder, torso, "Pocket", Vector3.new(0.45, 0.4, 0.12), CFrame.new(0.3, -torso.Size.Y * 0.3, front - 0.05), Color3.fromRGB(255, 255, 255), Enum.Material.Fabric)
	for side = -1, 1, 2 do
		attachBar(folder, torso, "Strap", Vector3.new(0.15, torso.Size.Y * 0.4, 0.08), CFrame.new(side * torso.Size.X * 0.3, torso.Size.Y * 0.3, front), color, Enum.Material.Fabric)
	end
end

local function bunnyEars(folder: Folder, head: BasePart, color: Color3)
	attachBar(folder, head, "Headband", Vector3.new(head.Size.X * 1.05, 0.15, 0.25), CFrame.new(0, head.Size.Y * 0.45, 0), Color3.fromRGB(255, 150, 200))
	for side = -1, 1, 2 do
		local offset = CFrame.new(side * 0.35, head.Size.Y * 0.45 + 0.75, 0) * CFrame.Angles(0, 0, math.rad(side * -10))
		attachBlob(folder, head, "Ear", Vector3.new(0.4, 1.4, 0.25), offset, color)
		attachBlob(folder, head, "EarInner", Vector3.new(0.22, 1, 0.08), offset * CFrame.new(0, -0.05, -0.1), Color3.fromRGB(255, 170, 205))
	end
end

local function idolJacket(folder: Folder, torso: BasePart, color: Color3)
	local shell = attachBar(folder, torso, "Jacket", torso.Size + Vector3.new(0.12, -0.1, 0.12), CFrame.new(0, 0.05, 0), color, Enum.Material.Fabric)
	for side = -1, 1, 2 do
		attachBar(folder, torso, "Trim", Vector3.new(0.08, torso.Size.Y * 0.9, 0.05), CFrame.new(side * 0.25, 0, -torso.Size.Z / 2 - 0.1), StoreConfig.Effects.TipGold, Enum.Material.Neon)
	end
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = StoreConfig.Effects.SparkleTexture
	sparkle.Color = ColorSequence.new(StoreConfig.Effects.TipGold, Color3.fromRGB(255, 200, 255))
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new(0.35, 0)
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Rate = 6
	sparkle.Speed = NumberRange.new(0.5, 1)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Parent = shell
end

local function lightstick(folder: Folder, hand: BasePart, color: Color3)
	local grip = CFrame.new(0, -hand.Size.Y / 2 - 0.3, -0.2)
	attachBar(folder, hand, "Handle", Vector3.new(0.18, 0.9, 0.18), grip, Color3.fromRGB(255, 255, 255))
	local glow = attachBlob(folder, hand, "Glow", Vector3.new(0.6, 0.6, 0.35), grip * CFrame.new(0, 0.7, 0), color, Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 1.2
	light.Range = 10
	light.Parent = glow
end

local function title(folder: Folder, head: BasePart, text: string, vip: boolean)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Title"
	gui.Size = UDim2.fromOffset(220, 30)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 60
	gui.Adornee = head
	gui.Parent = folder
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = if vip then StoreConfig.Effects.TipGold else StoreConfig.Colors.Neon
	label.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 2
	stroke.Parent = label
end

function Cosmetics.apply(player: Player)
	local character = player.Character
	local data = PlayerData.get(player)
	if not character or not data then
		return
	end
	local old = character:FindFirstChild("Cosmetics")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Cosmetics"

	local torso = find(character, { "UpperTorso", "Torso" })
	local head = find(character, { "Head" })
	local leftHand = find(character, { "LeftHand", "Left Arm" })

	local outfit = data.Equipped.Outfit and Catalog.get(data.Equipped.Outfit)
	if outfit and outfit.Color then
		if outfit.Id == "BunnyEars" and head then
			bunnyEars(folder, head, outfit.Color)
		elseif outfit.Id == "IdolJacket" and torso then
			idolJacket(folder, torso, outfit.Color)
		elseif torso then
			apron(folder, torso, outfit.Color)
		end
	end

	local stick = data.Equipped.Lightstick and Catalog.get(data.Equipped.Lightstick)
	if stick and stick.Color and leftHand then
		lightstick(folder, leftHand, stick.Color)
	end

	local titleItem = data.Equipped.Title and Catalog.get(data.Equipped.Title)
	if titleItem and head then
		title(folder, head, titleItem.Name, titleItem.Id == "VIP")
	end

	folder.Parent = character
end

function Cosmetics.init()
	local function watch(player: Player)
		player.CharacterAppearanceLoaded:Connect(function()
			Cosmetics.apply(player)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	PlayerData.onLoaded(function(player)
		Cosmetics.apply(player)
	end)
end

return Cosmetics
