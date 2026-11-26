--!strict
-- Store upgrades are shared: if anyone in the server owns one, the whole store has it.
-- Each is published as a ReplicatedStorage attribute ("Upgrade_TipJar" = true) for the UI.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)

local Upgrades = {}

local active: { [string]: boolean } = {}
local changed = Instance.new("BindableEvent")

function Upgrades.has(id: string): boolean
	return active[id] == true
end

-- Runs `callback` now and whenever the set of active upgrades changes.
function Upgrades.onChanged(callback: () -> ())
	changed.Event:Connect(callback)
	task.spawn(callback)
end

function Upgrades.refresh()
	local now: { [string]: boolean } = {}
	for _, player in Players:GetPlayers() do
		local data = PlayerData.get(player)
		if data then
			for _, item in Catalog.Items do
				if item.Kind == "Upgrade" and data.Owned[item.Id] then
					now[item.Id] = true
				end
			end
		end
	end
	local different = false
	for _, item in Catalog.Items do
		if item.Kind == "Upgrade" and (now[item.Id] or false) ~= (active[item.Id] or false) then
			different = true
		end
		if item.Kind == "Upgrade" then
			ReplicatedStorage:SetAttribute("Upgrade_" .. item.Id, now[item.Id] == true)
		end
	end
	active = now
	if different then
		changed:Fire()
	end
end

function Upgrades.init()
	PlayerData.onLoaded(Upgrades.refresh)
	Players.PlayerRemoving:Connect(function()
		task.defer(Upgrades.refresh)
	end)
	Upgrades.refresh()
end

return Upgrades
