local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Enums", {
	read = function(_stream)
		return Enum
	end,
	write = function(_stream) end,
})
