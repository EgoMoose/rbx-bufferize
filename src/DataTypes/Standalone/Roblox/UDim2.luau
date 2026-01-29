local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("UDim2", {
	read = function(stream)
		return UDim2.new(stream:readf32(), stream:readi32(), stream:readf32(), stream:readi32())
	end,
	write = function(stream, udim2)
		stream:writef32(udim2.X.Scale)
		stream:writei32(udim2.X.Offset)
		stream:writef32(udim2.Y.Scale)
		stream:writei32(udim2.Y.Offset)
	end,
})
