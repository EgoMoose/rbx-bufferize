local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Ray", {
	read = function(stream)
		return Ray.new(
			Vector3.new(stream:readf32(), stream:readf32(), stream:readf32()),
			Vector3.new(stream:readf32(), stream:readf32(), stream:readf32())
		)
	end,
	write = function(stream, ray)
		stream:writef32(ray.Origin.X)
		stream:writef32(ray.Origin.Y)
		stream:writef32(ray.Origin.Z)
		stream:writef32(ray.Direction.X)
		stream:writef32(ray.Direction.Y)
		stream:writef32(ray.Direction.Z)
	end,
})
