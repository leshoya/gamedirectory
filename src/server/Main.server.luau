--!strict
-- Entry point: builds the store, loads players' saved progress, turns on the stations and
-- the shop, and starts the night shift.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local StoreBuilder = require(script.Parent.Store.StoreBuilder)
local Decor = require(script.Parent.Store.Decor)
local PlayerData = require(script.Parent.Data.PlayerData)
local Tips = require(script.Parent.Economy.Tips)
local Upgrades = require(script.Parent.Economy.Upgrades)
local Inventory = require(script.Parent.Economy.Inventory)
local Shop = require(script.Parent.Economy.Shop)
local Monetization = require(script.Parent.Economy.Monetization)
local Cosmetics = require(script.Parent.Cosmetics.Cosmetics)
local Rulebook = require(script.Parent.Progress.Rulebook)
local Intro = require(script.Parent.Progress.Intro)
local HeldItem = require(script.Parent.Items.HeldItem)
local MakerStation = require(script.Parent.Stations.MakerStation)
local DrinkStation = require(script.Parent.Stations.DrinkStation)
local Power = require(script.Parent.Shift.Power)
local NightController = require(script.Parent.Shift.NightController)

local store = StoreBuilder.build()

-- Saved progress and the economy
PlayerData.init()
Tips.init()
Upgrades.init()
Inventory.init()
Rulebook.init()
Shop.init()
Monetization.init()
Cosmetics.init()
Upgrades.onChanged(function()
	Decor.setStickers(Upgrades.has("StickerWall"))
end)

-- Stations
HeldItem.init()
DrinkStation.init(store.DrinkSpots)
MakerStation.init(store.HotWater, {
	Item = "Ramen",
	Config = StoreConfig.Ramen,
	ObjectText = "Hot water",
	ActionText = "Make hot ramen",
})

-- The shift
Power.init(store.Lights, store.Breaker)
Intro.init()
NightController.start()
