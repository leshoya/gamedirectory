--!strict
-- Sends customers in one at a time, forever. Customers live in workspace.Customers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Customer = require(script.Parent.Customer)

local CustomerSpawner = {}

local function getFolder(): Folder
	local existing = workspace:FindFirstChild("Customers")
	if existing and existing:IsA("Folder") then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = "Customers"
	folder.Parent = workspace
	return folder
end

function CustomerSpawner.start()
	local cfg = StoreConfig.Customers
	local folder = getFolder()
	task.spawn(function()
		task.wait(cfg.FirstDelay)
		while true do
			local ok, err = pcall(Customer.run, folder)
			if not ok then
				warn("Customer visit failed: " .. tostring(err))
				folder:ClearAllChildren() -- don't leave a stuck customer behind
			end
			task.wait(cfg.SpawnDelay)
		end
	end)
end

return CustomerSpawner
