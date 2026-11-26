--!strict
-- Remotes the client UI talks to, in ReplicatedStorage.Remotes:
--   ShiftEvent (RemoteEvent): night summaries and the end-of-shift card
--   Shop (RemoteFunction): buy and equip
-- (Sounds and effects use the separate Feedback remote; see Feedback.luau.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = {}

local folder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local function get(className: string, name: string): Instance
	local existing = folder:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end
	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = folder
	return remote
end

Net.ShiftEvent = get("RemoteEvent", "ShiftEvent") :: RemoteEvent
Net.Shop = get("RemoteFunction", "Shop") :: RemoteFunction

return Net
