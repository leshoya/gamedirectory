--!strict
-- Entry point: builds the store, turns on its stations, and opens the doors to customers.

local StoreBuilder = require(script.Parent.Store.StoreBuilder)
local RegisterStation = require(script.Parent.Stations.RegisterStation)
local BubbleTeaStation = require(script.Parent.Stations.BubbleTeaStation)
local HeldItem = require(script.Parent.Items.HeldItem)
local Tips = require(script.Parent.Economy.Tips)
local CustomerSpawner = require(script.Parent.Customers.CustomerSpawner)

local store = StoreBuilder.build()
HeldItem.init()
Tips.init()
RegisterStation.init(store.Register)
BubbleTeaStation.init(store.Shaker)
CustomerSpawner.start()
