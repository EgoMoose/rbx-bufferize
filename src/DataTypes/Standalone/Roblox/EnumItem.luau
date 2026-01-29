local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("EnumItem", {
	read = function(stream)
		local enumName = stream:readString(stream:readu8())
		local enumType = (Enum :: any)[enumName] :: Enum
		return enumType:FromValue(stream:readu16()) :: EnumItem
	end,
	write = function(stream, enumItem)
		local enumTypeName = tostring(enumItem.EnumType)
		local length = #enumTypeName
		stream:writeu8(length)
		stream:writeString(enumTypeName, length)
		stream:writeu16(enumItem.Value)
	end,
})
