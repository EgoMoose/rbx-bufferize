local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("vector", {
	read = function(stream)
		local x = stream:readf32()
		local y = stream:readf32()
		local z = stream:readf32()
		return vector.create(x, y, z)
	end,
	write = function(stream, vec)
		stream:writef32(vec.x)
		stream:writef32(vec.y)
		stream:writef32(vec.z)
	end,
})
