--!strict
-- Saved progress per player: tips, Rulebook pages, owned items, what they're wearing, and stats.
-- If the data store can't be reached (for example in Studio without API access), the player
-- plays with fresh data that is not saved, so nothing real gets overwritten.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

export type Data = {
	Tips: number,
	Rulebook: { [string]: boolean },
	Owned: { [string]: boolean },
	Equipped: { [string]: string }, -- Kind -> item id
	Stats: { Caught: number, Nights: number, ShiftsWon: number },
	Flags: { [string]: boolean }, -- one-time things, like "SeenIntro"
}

local PlayerData = {}

local cache: { [Player]: Data } = {}
local unsaved: { [Player]: boolean } = {} -- players whose data failed to load: never saved
local loadedEvent = Instance.new("BindableEvent")

local store: DataStore? = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(StoreConfig.Data.StoreName)
	end)
	if ok then
		store = result
	else
		warn("Saving is off: " .. tostring(result))
	end
end

local function defaults(): Data
	return {
		Tips = 0,
		Rulebook = {},
		Owned = { NewHire = true, MintApron = true, PinkApron = true },
		Equipped = { Title = "NewHire" },
		Stats = { Caught = 0, Nights = 0, ShiftsWon = 0 },
		Flags = {},
	}
end

-- Fills in anything missing from older saves.
local function reconcile(saved: any): Data
	local data = defaults()
	if type(saved) ~= "table" then
		return data
	end
	data.Tips = tonumber(saved.Tips) or 0
	for _, key in { "Rulebook", "Owned", "Equipped", "Flags" } do
		if type(saved[key]) == "table" then
			for k, v in saved[key] do
				(data :: any)[key][k] = v
			end
		end
	end
	if type(saved.Stats) == "table" then
		for k, v in saved.Stats do
			(data.Stats :: any)[k] = tonumber(v) or 0
		end
	end
	return data
end

local function key(player: Player): string
	return "player_" .. player.UserId
end

local function load(player: Player)
	local data: Data? = nil
	if store then
		for attempt = 1, 3 do
			local ok, result = pcall(function()
				return (store :: DataStore):GetAsync(key(player))
			end)
			if ok then
				data = reconcile(result)
				break
			end
			warn(("Couldn't load data for %s (try %d): %s"):format(player.Name, attempt, tostring(result)))
			if string.find(tostring(result), "Studio access", 1, true) then
				break -- retrying won't help: Studio's API access setting is off
			end
			task.wait(attempt)
		end
	end
	if not data then
		unsaved[player] = true
		data = defaults()
	end
	if player.Parent then
		cache[player] = data
		loadedEvent:Fire(player, data)
	end
end

function PlayerData.save(player: Player)
	local data = cache[player]
	if not data or not store or unsaved[player] then
		return
	end
	local ok, err = pcall(function()
		(store :: DataStore):SetAsync(key(player), data)
	end)
	if not ok then
		warn(("Couldn't save data for %s: %s"):format(player.Name, tostring(err)))
	end
end

function PlayerData.get(player: Player): Data?
	return cache[player]
end

-- Runs `callback` for each player once their data is ready (including players already loaded).
function PlayerData.onLoaded(callback: (Player, Data) -> ())
	loadedEvent.Event:Connect(callback)
	for player, data in cache do
		task.spawn(callback, player, data)
	end
end

function PlayerData.init()
	Players.PlayerAdded:Connect(load)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		PlayerData.save(player)
		cache[player] = nil
		unsaved[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(StoreConfig.Data.AutosaveEvery)
			for player in cache do
				task.spawn(PlayerData.save, player)
			end
		end
	end)
	game:BindToClose(function()
		for player in cache do
			PlayerData.save(player)
		end
	end)
end

return PlayerData
