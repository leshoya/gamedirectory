--!strict
-- The Sticker Wall upgrade: heart and star stickers scattered over the walls.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local PartFactory = require(script.Parent.PartFactory)

local Decor = {}

local STICKERS = { "♥", "★", "♥", "✿" }

local function sticker(parent: Instance, position: Vector3, face: Enum.NormalId, text: string, color: Color3)
	local part = PartFactory.part({
		Name = "Sticker",
		Size = Vector3.new(1.2, 1.2, 1.2),
		CFrame = CFrame.new(position),
		Transparency = 1,
		CanCollide = false,
		Parent = parent,
	})
	part.CanQuery = false
	PartFactory.label(part, face, text, color)
end

function Decor.setStickers(on: boolean)
	local store = workspace:FindFirstChild("Store")
	if not store then
		return
	end
	local existing = store:FindFirstChild("Stickers")
	if existing then
		existing:Destroy()
	end
	if not on then
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "Stickers"
	local rng = Random.new(14)
	local S = StoreConfig.Size
	for i = 1, 14 do
		local text = STICKERS[(i - 1) % #STICKERS + 1]
		local color = StoreConfig.Products[rng:NextInteger(1, #StoreConfig.Products)]
		local y = StoreConfig.FloorY + rng:NextNumber(5.5, 10)
		if i % 2 == 0 then
			-- left wall, facing into the store (+X is the Right face)
			sticker(folder, Vector3.new(-S.Width / 2 + 0.7, y, rng:NextNumber(-12, 12)), Enum.NormalId.Right, text, color)
		else
			-- back wall, facing into the store (+Z is the Back face)
			sticker(folder, Vector3.new(rng:NextNumber(-18, 18), y, -S.Depth / 2 + 0.7), Enum.NormalId.Back, text, color)
		end
	end
	folder.Parent = store
end

return Decor
