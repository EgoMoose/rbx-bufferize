local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("UDim", {
	read = function(stream)
		return UDim.new(stream:readf32(), stream:readi32())
	end,
	write = function(stream, udim)
		stream:writef32(udim.Scale)
		stream:writei32(udim.Offset)
	end,
})
