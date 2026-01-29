local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Enum", {
	read = function(stream)
		local enumTypeName = stream:readString(stream:readu8())
		return (Enum :: any)[enumTypeName] :: Enum
	end,
	write = function(stream, enumType)
		local enumTypeName = tostring(enumType)
		local length = #enumTypeName
		stream:writeu8(length)
		stream:writeString(enumTypeName, length)
	end,
})
