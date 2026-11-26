--!strict
-- Small helpers for making anchored, smooth parts and text signs.

local PartFactory = {}

export type PartProps = {
	Name: string?,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3?,
	Material: Enum.Material?,
	Transparency: number?,
	CanCollide: boolean?,
	Shape: Enum.PartType?,
	Parent: Instance?,
}

function PartFactory.part(props: PartProps): Part
	local part = Instance.new("Part")
	part.Name = props.Name or "Part"
	part.Anchored = true
	part.Shape = props.Shape or Enum.PartType.Block -- set before Size
	part.Size = props.Size
	part.CFrame = props.CFrame
	part.Color = props.Color or Color3.new(1, 1, 1)
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.Transparency = props.Transparency or 0
	part.CanCollide = if props.CanCollide == nil then true else props.CanCollide
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = props.Parent
	return part
end

-- A block placed by the center of its bottom face.
function PartFactory.box(
	parent: Instance,
	name: string,
	size: Vector3,
	bottom: Vector3,
	color: Color3,
	material: Enum.Material?
): Part
	return PartFactory.part({
		Name = name,
		Size = size,
		CFrame = CFrame.new(bottom + Vector3.new(0, size.Y / 2, 0)),
		Color = color,
		Material = material,
		Parent = parent,
	})
end

-- An upright cylinder placed by the center of its bottom.
function PartFactory.cup(parent: Instance, name: string, height: number, diameter: number, bottom: Vector3, color: Color3): Part
	return PartFactory.part({
		Name = name,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, diameter, diameter), -- cylinders run along X
		CFrame = CFrame.new(bottom + Vector3.new(0, height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = color,
		Parent = parent,
	})
end

-- Text drawn on one face of a part. Returns the label so callers can change the text.
function PartFactory.label(part: BasePart, face: Enum.NormalId, text: string, textColor: Color3): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Label"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = textColor
	label.Text = text
	label.Parent = gui
	return label
end

return PartFactory
