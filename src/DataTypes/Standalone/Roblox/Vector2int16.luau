local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Vector2int16", {
	read = function(stream)
		local x = stream:readi16()
		local y = stream:readi16()
		return Vector2int16.new(x, y)
	end,
	write = function(stream, vec)
		stream:writei16(vec.X)
		stream:writei16(vec.Y)
	end,
})
