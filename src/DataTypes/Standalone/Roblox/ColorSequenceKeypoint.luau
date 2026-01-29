local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("ColorSequenceKeypoint", {
	read = function(stream)
		local t = stream:readf32()
		local color = Color3.fromRGB(stream:readu8(), stream:readu8(), stream:readu8())
		return ColorSequenceKeypoint.new(t, color)
	end,
	write = function(stream, kp)
		local rHex, gHex, bHex = kp.Value:ToHex():match("(..)(..)(..)")
		stream:writef32(kp.Time)
		stream:writeu8(tonumber(rHex, 16) :: number)
		stream:writeu8(tonumber(gHex, 16) :: number)
		stream:writeu8(tonumber(bHex, 16) :: number)
	end,
})
