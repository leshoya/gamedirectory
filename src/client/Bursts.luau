--!strict
-- One-shot particle bursts: pink hearts when a customer is happy, golden sparkles for treats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

type Style = {
	Texture: string,
	Colors: ColorSequence,
	Count: number,
	Size: number,
	Speed: NumberRange,
	Lifetime: NumberRange,
	Acceleration: Vector3,
	LightEmission: number,
}

local fx = StoreConfig.Effects

local STYLES: { [string]: Style } = {
	Hearts = {
		Texture = fx.HeartTexture,
		Colors = ColorSequence.new(Color3.fromRGB(255, 130, 180), Color3.fromRGB(255, 190, 220)),
		Count = 12,
		Size = 0.7,
		Speed = NumberRange.new(4, 7),
		Lifetime = NumberRange.new(0.9, 1.4),
		Acceleration = Vector3.new(0, -4, 0),
		LightEmission = 0.3,
	},
	Sparkles = {
		Texture = fx.SparkleTexture,
		Colors = ColorSequence.new(fx.TipGold, Color3.fromRGB(255, 240, 200)),
		Count = 20,
		Size = 0.9,
		Speed = NumberRange.new(3, 6),
		Lifetime = NumberRange.new(0.6, 1.1),
		Acceleration = Vector3.new(0, -2, 0),
		LightEmission = 1,
	},
}

local Bursts = {}

function Bursts.play(styleName: string, position: Vector3)
	local style = STYLES[styleName]
	if not style then
		warn("No burst style named " .. styleName)
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = position
	attachment.Parent = workspace.Terrain

	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Texture = style.Texture
	emitter.Color = style.Colors
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.15, style.Size),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Speed = style.Speed
	emitter.Lifetime = style.Lifetime
	emitter.Acceleration = style.Acceleration
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Rotation = NumberRange.new(-20, 20)
	emitter.LightEmission = style.LightEmission
	emitter.Parent = attachment
	emitter:Emit(style.Count)

	Debris:AddItem(attachment, style.Lifetime.Max + 0.5)
end

return Bursts
