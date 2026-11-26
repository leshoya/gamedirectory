--!strict
-- The shop: store upgrades, looks, lightsticks and titles. Tips items are bought through the
-- Shop remote; Robux items open a Roblox purchase prompt (or say Coming soon if not set up).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)

local C = StoreConfig.Colors
local FX = StoreConfig.Effects

local TABS = {
	{ Kind = "Upgrade", Label = "Store" },
	{ Kind = "Outfit", Label = "Looks" },
	{ Kind = "Lightstick", Label = "Lightsticks" },
	{ Kind = "Title", Label = "Titles" },
}

local ShopUi = {}

local function ownedSet(player: Player): { [string]: boolean }
	local set = {}
	for id in string.gmatch((player:GetAttribute("Owned") or "") :: string, "[^,]+") do
		set[id] = true
	end
	return set
end

function ShopUi.build(gui: ScreenGui): Frame
	local player = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop") :: RemoteFunction

	local panel = Ui.panel(gui, "Shop", UDim2.fromOffset(580, 420), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	panel.Visible = false
	Ui.label(panel, "Shop", UDim2.fromOffset(120, 36), UDim2.fromOffset(20, 12), C.Neon, Enum.TextXAlignment.Left)
	Ui.button(panel, "X", UDim2.fromOffset(36, 36), UDim2.new(1, -50, 0, 12), C.Trim, function()
		panel.Visible = false
	end)
	local toast = Ui.label(panel, "", UDim2.new(1, -40, 0, 22), UDim2.new(0, 20, 1, -32), C.SignText)

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -40, 1, -150)
	list.Position = UDim2.fromOffset(20, 104)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local currentKind = "Upgrade"
	local render: () -> ()

	local function act(action: string, id: string)
		local ok, reply = pcall(function()
			return remote:InvokeServer(action, id)
		end)
		toast.Text = if ok and reply then reply.Message else "Try again in a moment."
		task.delay(2.5, function()
			toast.Text = ""
		end)
	end

	local function buyRobux(item: Catalog.Item)
		local productId = item.Robux and StoreConfig.Monetization.Products[item.Robux] or 0
		if productId and productId > 0 then
			MarketplaceService:PromptProductPurchase(player, productId)
		else
			toast.Text = "Coming soon!"
		end
	end

	local function itemRow(item: Catalog.Item, order: number, owned: boolean, equipped: boolean)
		local rowFrame = Instance.new("Frame")
		rowFrame.Size = UDim2.new(1, -10, 0, 64)
		rowFrame.LayoutOrder = order
		rowFrame.BackgroundColor3 = if owned then Color3.fromRGB(250, 240, 250) else Color3.fromRGB(255, 255, 255)
		rowFrame.Parent = list
		Ui.corner(rowFrame, UDim.new(0, 10))
		Ui.stroke(rowFrame, C.Trim, 2)
		if item.Color then
			local swatch = Instance.new("Frame")
			swatch.Size = UDim2.fromOffset(36, 36)
			swatch.Position = UDim2.fromOffset(12, 14)
			swatch.BackgroundColor3 = item.Color
			swatch.Parent = rowFrame
			Ui.corner(swatch, UDim.new(0.5, 0))
		end
		local x = if item.Color then 58 else 14
		Ui.label(rowFrame, item.Name, UDim2.new(1, -x - 150, 0, 26), UDim2.fromOffset(x, 6), C.SignText, Enum.TextXAlignment.Left)
		local desc = Ui.label(rowFrame, item.Description, UDim2.new(1, -x - 150, 0, 20), UDim2.fromOffset(x, 36), C.Trim:Lerp(C.SignText, 0.5), Enum.TextXAlignment.Left)
		desc.Font = Enum.Font.Gotham

		local size, position = UDim2.fromOffset(128, 40), UDim2.new(1, -140, 0, 12)
		if item.Kind == "Upgrade" and owned then
			Ui.label(rowFrame, "In the store", size, position, FX.Good)
		elseif owned then
			Ui.button(rowFrame, if equipped then "Wearing" else "Wear", size, position, if equipped then FX.Good else C.Trim, function()
				act("Equip", item.Id)
			end)
		elseif item.Robux then
			Ui.button(rowFrame, "Robux", size, position, FX.TipGold, function()
				buyRobux(item)
			end)
		elseif item.Earned then
			Ui.label(rowFrame, "Earn it!", size, position, C.Trim:Lerp(C.SignText, 0.4))
		elseif item.Price then
			Ui.button(rowFrame, if item.Price == 0 then "Free" else item.Price .. " tips", size, position, C.Neon, function()
				act("Buy", item.Id)
			end)
		end
	end

	render = function()
		for _, child in list:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		local owned = ownedSet(player)
		local equipped = player:GetAttribute("Equipped_" .. currentKind)
		for i, item in Catalog.Items do
			if item.Kind == currentKind then
				itemRow(item, i, owned[item.Id] == true, equipped == item.Id)
			end
		end
	end

	local tabButtons = {}
	for i, tab in TABS do
		tabButtons[tab.Kind] = Ui.button(panel, tab.Label, UDim2.fromOffset(124, 36), UDim2.fromOffset(20 + (i - 1) * 134, 56), C.Trim, function()
			currentKind = tab.Kind
			for kind, button in tabButtons do
				button.BackgroundColor3 = if kind == currentKind then C.Neon else C.Trim
			end
			render()
		end)
	end
	tabButtons.Upgrade.BackgroundColor3 = C.Neon

	for _, attribute in { "Owned", "Equipped_Outfit", "Equipped_Lightstick", "Equipped_Title" } do
		player:GetAttributeChangedSignal(attribute):Connect(function()
			if panel.Visible then
				render()
			end
		end)
	end
	panel:GetPropertyChangedSignal("Visible"):Connect(function()
		if panel.Visible then
			render()
		end
	end)
	return panel
end

return ShopUi
