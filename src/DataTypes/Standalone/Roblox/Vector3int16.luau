local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Vector3int16", {
	read = function(stream)
		local x = stream:readi16()
		local y = stream:readi16()
		local z = stream:readi16()
		return Vector3int16.new(x, y, z)
	end,
	write = function(stream, vec)
		stream:writei16(vec.X)
		stream:writei16(vec.Y)
		stream:writei16(vec.Z)
	end,
})
