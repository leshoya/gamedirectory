--!strict
-- The sticker Rulebook: one page per anomaly. Spotted pages show the tell; the rest are "???".

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Anomalies = require(ReplicatedStorage.Shared.Anomalies)
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)

local C = StoreConfig.Colors

local RulebookUi = {}

function RulebookUi.build(gui: ScreenGui): Frame
	local player = Players.LocalPlayer
	local panel = Ui.panel(gui, "Rulebook", UDim2.fromOffset(560, 380), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	panel.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
	panel.Visible = false
	local header = Ui.label(panel, "Rulebook", UDim2.new(1, -120, 0, 36), UDim2.fromOffset(20, 12), C.Neon, Enum.TextXAlignment.Left)
	Ui.button(panel, "X", UDim2.fromOffset(36, 36), UDim2.new(1, -50, 0, 12), C.Trim, function()
		panel.Visible = false
	end)

	local grid = Instance.new("Frame")
	grid.BackgroundTransparency = 1
	grid.Size = UDim2.new(1, -40, 1, -70)
	grid.Position = UDim2.fromOffset(20, 58)
	grid.Parent = panel
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0.25, -9, 0.5, -8)
	layout.CellPadding = UDim2.fromOffset(12, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid

	local pages = {}
	for i, anomaly in Anomalies.List do
		local page = Instance.new("Frame")
		page.LayoutOrder = i
		page.Parent = grid
		Ui.corner(page)
		Ui.stroke(page, C.Trim, 2)
		local name = Ui.label(page, "", UDim2.new(1, -12, 0, 24), UDim2.fromOffset(6, 8), C.SignText)
		local tell = Ui.label(page, "", UDim2.new(1, -16, 1, -64), UDim2.fromOffset(8, 36), C.SignText)
		tell.TextWrapped = true
		tell.TextScaled = true
		local night = Ui.label(page, "Night " .. anomaly.FirstNight .. "+ · " .. anomaly.Type, UDim2.new(1, -12, 0, 16), UDim2.new(0, 6, 1, -22), C.Trim:Lerp(C.SignText, 0.4))
		night.Font = Enum.Font.Gotham
		pages[anomaly.Id] = { Frame = page, Name = name, Tell = tell, Anomaly = anomaly }
	end

	local function refresh()
		local found = {}
		for id in string.gmatch((player:GetAttribute("Rulebook") or "") :: string, "[^,]+") do
			found[id] = true
		end
		local count = 0
		for id, page in pages do
			if found[id] then
				count += 1
				page.Frame.BackgroundColor3 = Color3.fromRGB(255, 228, 240)
				page.Name.Text = page.Anomaly.Name
				page.Tell.Text = page.Anomaly.Tell
			else
				page.Frame.BackgroundColor3 = Color3.fromRGB(236, 232, 240)
				page.Name.Text = "???"
				page.Tell.Text = "Not spotted yet. Turn one away to fill this page."
			end
		end
		header.Text = ("Rulebook  %d / %d"):format(count, #Anomalies.List)
	end
	player:GetAttributeChangedSignal("Rulebook"):Connect(refresh)
	refresh()
	return panel
end

return RulebookUi
