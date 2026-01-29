local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("nil", {
	read = function(_stream)
		return nil
	end,
	write = function(_stream, _null) end,
})
