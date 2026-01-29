local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("NumberRange", {
	read = function(stream)
		return NumberRange.new(stream:readf32(), stream:readf32())
	end,
	write = function(stream, range)
		stream:writef32(range.Min)
		stream:writef32(range.Max)
	end,
})
