--!strict
-- The store's lights and the breaker box. Power.cut() turns the lights off and arms the breaker;
-- holding E at the breaker turns them back on. Published as the ReplicatedStorage "PowerOut" attribute.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Feedback = require(script.Parent.Parent.Feedback)

local Power = {}

local panels: { BasePart } = {}
local lights: { Light } = {}
local prompt: ProximityPrompt? = nil
local out = false
local restoredEvent = Instance.new("BindableEvent")
Power.Restored = restoredEvent.Event

local function setLights(on: boolean)
	for _, light in lights do
		light.Enabled = on
	end
	for _, panel in panels do
		panel.Material = if on then Enum.Material.Neon else Enum.Material.SmoothPlastic
		panel.Color = if on then StoreConfig.Colors.Light else Color3.fromRGB(70, 65, 80)
	end
	Lighting.Ambient = if on then StoreConfig.Lighting.Ambient else StoreConfig.Power.OutageAmbient
end

function Power.isOut(): boolean
	return out
end

function Power.cut()
	if out then
		return
	end
	out = true
	setLights(false)
	ReplicatedStorage:SetAttribute("PowerOut", true)
	if prompt then
		prompt.Enabled = true
	end
	Feedback.sound("Sad")
end

function Power.restore()
	if not out then
		return
	end
	out = false
	setLights(true)
	ReplicatedStorage:SetAttribute("PowerOut", false)
	if prompt then
		prompt.Enabled = false
	end
	restoredEvent:Fire()
end

-- A quick flash of light while the power is out.
function Power.flicker(duration: number)
	if not out then
		return
	end
	setLights(true)
	task.wait(duration)
	if out then
		setLights(false)
	end
end

function Power.init(ceiling: Instance, breaker: BasePart)
	for _, d in ceiling:GetDescendants() do
		if d:IsA("Light") then
			table.insert(lights, d)
		elseif d:IsA("BasePart") and d.Name == "LightPanel" then
			table.insert(panels, d)
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Parent = breaker
	local p = Instance.new("ProximityPrompt")
	p.ObjectText = "Breaker"
	p.ActionText = "Reset breaker"
	p.HoldDuration = StoreConfig.Power.ResetHold
	p.MaxActivationDistance = 8
	p.RequiresLineOfSight = false
	p.Enabled = false
	p.Parent = attachment
	p.Triggered:Connect(function()
		Power.restore()
		Feedback.sound("Register", breaker.Position)
		Feedback.popup("Lights on!", breaker.Position + Vector3.new(-1, 2, 0), StoreConfig.Effects.Good)
	end)
	prompt = p
	ReplicatedStorage:SetAttribute("PowerOut", false)
end

return Power
