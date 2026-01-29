local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("boolean", {
	read = function(stream)
		return stream:readu8() == 1
	end,
	write = function(stream, value)
		stream:writeu8(if value then 1 else 0)
	end,
})
