--!strict
-- Listens for the server's Feedback remote (src/server/Feedback.luau) and plays each effect.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sounds = require(script.Parent.Sounds)
local Popups = require(script.Parent.Popups)
local Bursts = require(script.Parent.Bursts)
local Jumpscare = require(script.Parent.Jumpscare)

type Message = {
	Kind: string,
	Name: string?,
	Text: string?,
	Style: string?,
	Position: Vector3?,
	Color: Color3?,
	Speed: number?,
	Model: Model?,
	Size: ("Small" | "Big")?,
}

local FeedbackClient = {}

local function handle(message: Message)
	if message.Kind == "Sound" and message.Name then
		Sounds.play(message.Name, message.Position, message.Speed)
	elseif message.Kind == "Popup" and message.Text and message.Position then
		Popups.show(message.Text, message.Position, message.Color or Color3.new(1, 1, 1))
	elseif message.Kind == "Burst" and message.Style and message.Position then
		Bursts.play(message.Style, message.Position)
	elseif message.Kind == "Jumpscare" then
		task.spawn(Jumpscare.play, message.Model, message.Size or "Small")
	end
end

function FeedbackClient.init()
	local remote = ReplicatedStorage:WaitForChild("Feedback") :: RemoteEvent
	remote.OnClientEvent:Connect(handle)
end

return FeedbackClient
