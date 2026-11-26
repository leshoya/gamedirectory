--!strict
-- Tells clients to play sounds, popups and particle bursts. The server decides what happens;
-- each client draws it, so effects stay smooth and nothing heavy is replicated.
-- The client side lives in src/client/FeedbackClient.luau.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAME = "Feedback"

local function getRemote(): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
	return remote
end

local remote = getRemote()

local Feedback = {}

-- Plays a sound from StoreConfig.Sounds; at a position if given, otherwise everywhere.
function Feedback.sound(name: string, position: Vector3?)
	remote:FireAllClients({ Kind = "Sound", Name = name, Position = position })
end

-- Floating text that rises and fades, like "+12" or "Speedy!".
function Feedback.popup(text: string, position: Vector3, color: Color3)
	remote:FireAllClients({ Kind = "Popup", Text = text, Position = position, Color = color })
end

-- A particle burst: "Hearts" or "Sparkles".
function Feedback.burst(style: string, position: Vector3)
	remote:FireAllClients({ Kind = "Burst", Style = style, Position = position })
end

return Feedback
