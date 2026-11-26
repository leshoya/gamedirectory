--!strict
-- Buttons in the bottom-left corner: the Rulebook, the Shop, and Help (replays the manager's intro).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Ui = require(script.Parent.Ui)
local RulebookUi = require(script.Parent.RulebookUi)
local ShopUi = require(script.Parent.ShopUi)
local Intro = require(script.Parent.Intro)

local Menu = {}

function Menu.init()
	local gui = Ui.screen("Menu", 3)
	local rulebook = RulebookUi.build(gui)
	local shop = ShopUi.build(gui)

	Ui.button(gui, "Rulebook", UDim2.fromOffset(130, 44), UDim2.new(0, 16, 1, -64), StoreConfig.Colors.Trim, function()
		shop.Visible = false
		rulebook.Visible = not rulebook.Visible
	end)
	Ui.button(gui, "Shop", UDim2.fromOffset(110, 44), UDim2.new(0, 156, 1, -64), StoreConfig.Colors.Neon, function()
		rulebook.Visible = false
		shop.Visible = not shop.Visible
	end)
	Ui.button(gui, "Help", UDim2.fromOffset(90, 44), UDim2.new(0, 276, 1, -64), StoreConfig.Colors.SignText, function()
		rulebook.Visible = false
		shop.Visible = false
		task.spawn(Intro.play)
	end)
end

return Menu
