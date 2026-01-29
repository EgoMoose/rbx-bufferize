local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("buffer", {
	read = function(stream)
		return stream:readBuffer(stream:readu32())
	end,
	write = function(stream, b)
		local length = buffer.len(b)
		stream:writeu32(length)
		stream:writeBuffer(b, 0, length)
	end,
})
