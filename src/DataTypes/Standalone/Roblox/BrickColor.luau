local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("BrickColor", {
	read = function(stream)
		return BrickColor.new(stream:readu32())
	end,
	write = function(stream, brickColor)
		stream:writeu32(brickColor.Number)
	end,
})
