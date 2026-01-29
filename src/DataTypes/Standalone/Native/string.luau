local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("string", {
	read = function(stream)
		local bytes = stream:readu8()
		local length = stream:readUnsignedBytes(bytes)
		return stream:readString(length)
	end,
	write = function(stream, str)
		local length = #str

		local bytes = 4
		if length <= 0xFF then
			bytes = 1
		elseif length <= 0xFFFF then
			bytes = 2
		end

		stream:writeu8(bytes)
		stream:writeUnsignedBytes(bytes, length)
		stream:writeString(str, length)
	end,
})
