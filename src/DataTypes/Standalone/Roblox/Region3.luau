local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Region3", {
	read = function(stream)
		local vMin = Vector3.new(stream:readf32(), stream:readf32(), stream:readf32())
		local vMax = Vector3.new(stream:readf32(), stream:readf32(), stream:readf32())
		return Region3.new(vMin, vMax)
	end,
	write = function(stream, r3)
		local sx, sy, sz = r3.Size.X / 2, r3.Size.Y / 2, r3.Size.Z / 2
		local vMin = r3.CFrame * Vector3.new(-sx, -sy, -sz)
		local vMax = r3.CFrame * Vector3.new(sx, sy, sz)

		stream:writef32(math.min(vMin.X, vMax.X))
		stream:writef32(math.min(vMin.Y, vMax.Y))
		stream:writef32(math.min(vMin.Z, vMax.Z))
		stream:writef32(math.max(vMin.X, vMax.X))
		stream:writef32(math.max(vMin.Y, vMax.Y))
		stream:writef32(math.max(vMin.Z, vMax.Z))
	end,
})
