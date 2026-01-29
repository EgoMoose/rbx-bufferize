local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Vector2", {
	read = function(stream)
		local x = stream:readf32()
		local y = stream:readf32()
		return Vector2.new(x, y)
	end,
	write = function(stream, vec)
		stream:writef32(vec.X)
		stream:writef32(vec.Y)
	end,
})
