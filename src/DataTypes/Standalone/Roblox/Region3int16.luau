local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Region3int16", {
	read = function(stream)
		local vMin = Vector3int16.new(stream:readi16(), stream:readi16(), stream:readi16())
		local vMax = Vector3int16.new(stream:readi16(), stream:readi16(), stream:readi16())
		return Region3int16.new(vMin, vMax)
	end,
	write = function(stream, r3int16)
		local r3Min = r3int16.Min
		local r3Max = r3int16.Max

		stream:writei16(r3Min.X)
		stream:writei16(r3Min.Y)
		stream:writei16(r3Min.Z)
		stream:writei16(r3Max.X)
		stream:writei16(r3Max.Y)
		stream:writei16(r3Max.Z)
	end,
})
