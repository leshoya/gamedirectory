--!strict
-- Shape helpers for plush parts: soft ovals (blobs), points on an oval's surface, and thread stitches.

local PartFactory = require(script.Parent.Parent.Store.PartFactory)

export type Oval = { CFrame: CFrame, Size: Vector3 }

local Shapes = {}

-- An oval part (a block drawn with a sphere mesh, so it can be stretched on any axis).
function Shapes.blob(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part = PartFactory.part({
		Name = name,
		Size = size,
		CFrame = cframe,
		Color = color,
		Material = material or Enum.Material.Fabric,
		CanCollide = false,
	})
	part.CanQuery = false
	part.CanTouch = false
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = part
	part.Parent = parent
	return part
end

-- A plain block, for thin things like whiskers and drips.
function Shapes.bar(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part = PartFactory.part({
		Name = name,
		Size = size,
		CFrame = cframe,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Parent = parent
	return part
end

-- A flat triangle standing in the XY plane of `cframe` (point up, facing -Z), made of two
-- mirrored wedges. Used for pointy ears.
function Shapes.triangle(parent: Instance, name: string, width: number, height: number, thickness: number, cframe: CFrame, color: Color3)
	for side = -1, 1, 2 do
		local wedge = Instance.new("WedgePart")
		wedge.Name = name
		wedge.Anchored = true
		wedge.CanCollide = false
		wedge.CanQuery = false
		wedge.CanTouch = false
		wedge.Size = Vector3.new(thickness, height, width / 2)
		-- A wedge's upright edge is on its +Z side; turning it ±90° puts that edge on the center line.
		wedge.CFrame = cframe * CFrame.new(side * width / 4, 0, 0) * CFrame.Angles(0, -side * math.pi / 2, 0)
		wedge.Color = color
		wedge.Material = Enum.Material.Fabric
		wedge.TopSurface = Enum.SurfaceType.Smooth
		wedge.BottomSurface = Enum.SurfaceType.Smooth
		wedge.Parent = parent
	end
end

function Shapes.of(part: BasePart): Oval
	return { CFrame = part.CFrame, Size = part.Size }
end

-- The point on an oval's surface in direction `dir` (in the oval's own space), pushed `out`
-- studs off the surface. Its LookVector points straight out of the surface and its up stays upright,
-- so eyes, buttons and patches placed there face outward the right way up.
function Shapes.onSurface(oval: Oval, dir: Vector3, out: number?): CFrame
	local a, b, c = oval.Size.X / 2, oval.Size.Y / 2, oval.Size.Z / 2
	local k = math.sqrt((dir.X / a) ^ 2 + (dir.Y / b) ^ 2 + (dir.Z / c) ^ 2)
	local p = dir / k
	local normal = Vector3.new(p.X / (a * a), p.Y / (b * b), p.Z / (c * c)).Unit
	p += normal * (out or 0)
	local up = if math.abs(normal.Y) > 0.95 then Vector3.new(0, 0, -1) else Vector3.yAxis
	return oval.CFrame * CFrame.lookAt(p, p + normal, up)
end

-- Short thread dashes joining a list of surface points, like a running stitch.
function Shapes.stitches(parent: Instance, points: { CFrame }, color: Color3, thickness: number?)
	local t = thickness or 0.05
	for i = 1, #points - 1 do
		local p1, p2 = points[i].Position, points[i + 1].Position
		local span = p2 - p1
		if span.Magnitude > 0.01 then
			local normal = (points[i].LookVector + points[i + 1].LookVector).Unit
			local mid = (p1 + p2) / 2 + normal * 0.02
			Shapes.bar(parent, "Stitch", Vector3.new(t, t, span.Magnitude * 0.7), CFrame.lookAt(mid, mid + span, normal), color)
		end
	end
end

-- Surface points for a list of directions on one oval.
function Shapes.path(oval: Oval, dirs: { Vector3 }, out: number?): { CFrame }
	local points = {}
	for _, dir in dirs do
		table.insert(points, Shapes.onSurface(oval, dir, out))
	end
	return points
end

-- A darker shade of a color, for seams.
function Shapes.shade(color: Color3, amount: number): Color3
	return color:Lerp(Color3.new(0.15, 0.1, 0.2), amount)
end

return Shapes
