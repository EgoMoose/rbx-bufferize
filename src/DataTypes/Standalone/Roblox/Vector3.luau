local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Vector3", {
	read = function(stream)
		local x = stream:readf32()
		local y = stream:readf32()
		local z = stream:readf32()
		return Vector3.new(x, y, z)
	end,
	write = function(stream, vec)
		stream:writef32(vec.X)
		stream:writef32(vec.Y)
		stream:writef32(vec.Z)
	end,
})
