local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)
local CFrameStream = require(script.Parent.CFrame.CFrameStream)

return DataTypeDefinition.new("RotationCurveKey", {
	read = function(stream)
		local t = stream:readf32()
		local value = CFrameStream.read(stream)
		local interpolation = Enum.KeyInterpolationMode:FromValue(stream:readu16()) :: Enum.KeyInterpolationMode
		return RotationCurveKey.new(t, value, interpolation)
	end,
	write = function(stream, rck)
		stream:writef32(rck.Time)
		CFrameStream.write(stream, rck.Value)
		stream:writeu16(rck.Interpolation.Value)
	end,
})
