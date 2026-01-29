local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Rect", {
	read = function(stream)
		return Rect.new(stream:readf32(), stream:readf32(), stream:readf32(), stream:readf32())
	end,
	write = function(stream, rect)
		stream:writef32(rect.Min.X)
		stream:writef32(rect.Min.Y)
		stream:writef32(rect.Max.X)
		stream:writef32(rect.Max.Y)
	end,
})
