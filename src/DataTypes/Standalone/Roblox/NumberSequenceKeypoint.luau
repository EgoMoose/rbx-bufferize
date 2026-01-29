local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("NumberSequenceKeypoint", {
	read = function(stream)
		return NumberSequenceKeypoint.new(stream:readf32(), stream:readf32(), stream:readf32())
	end,
	write = function(stream, kp)
		stream:writef32(kp.Time)
		stream:writef32(kp.Value)
		stream:writef32(kp.Envelope)
	end,
})
