--!strict
-- The store's lights and the breaker box. Power.cut() turns every light inside the store off
-- (lamps, light panels, string lights, lanterns, the cooler) and arms the breaker; holding E at the
-- breaker turns them back on. Published as the ReplicatedStorage "PowerOut" attribute.
-- The street lamps and neon sign outside stay on, so the dark store glows from outside.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Feedback = require(script.Parent.Parent.Feedback)

local Power = {}

type Glowing = { Part: BasePart, Color: Color3 }

local glowing: { Glowing } = {}
local lights: { Light } = {}
local prompt: ProximityPrompt? = nil
local out = false
local restoredEvent = Instance.new("BindableEvent")
Power.Restored = restoredEvent.Event

local OFF_COLOR = Color3.fromRGB(70, 65, 80)

local function setLights(on: boolean)
	for _, light in lights do
		light.Enabled = on
	end
	for _, g in glowing do
		g.Part.Material = if on then Enum.Material.Neon else Enum.Material.SmoothPlastic
		g.Part.Color = if on then g.Color else g.Color:Lerp(OFF_COLOR, 0.7)
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

-- `containers` hold everything that should go dark: every Light and every Neon part inside them.
function Power.init(containers: { Instance }, breaker: BasePart)
	for _, container in containers do
		for _, d in container:GetDescendants() do
			if d:IsA("Light") then
				table.insert(lights, d)
			elseif d:IsA("BasePart") and d.Material == Enum.Material.Neon then
				table.insert(glowing, { Part = d, Color = d.Color })
			end
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
