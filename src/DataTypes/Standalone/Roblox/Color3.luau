local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Color3", {
	read = function(stream)
		return Color3.fromRGB(stream:readu8(), stream:readu8(), stream:readu8())
	end,
	write = function(stream, color)
		local rHex, gHex, bHex = color:ToHex():match("(..)(..)(..)")
		stream:writeu8(tonumber(rHex, 16) :: number)
		stream:writeu8(tonumber(gHex, 16) :: number)
		stream:writeu8(tonumber(bHex, 16) :: number)
	end,
})
