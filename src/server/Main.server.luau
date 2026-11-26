--!strict
-- Entry point: builds the store and turns on its stations.

local StoreBuilder = require(script.Parent.Store.StoreBuilder)
local RegisterStation = require(script.Parent.Stations.RegisterStation)

local store = StoreBuilder.build()
RegisterStation.init(store.Register)
