local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local function readTangent(stream: DataTypeDefinition.BufferStream, tangentId: number): number?
	local prevCursor = stream.cursor
	if stream:readu8() == tangentId then
		return stream:readf32()
	end
	stream.cursor = prevCursor
	return nil
end

return DataTypeDefinition.new("FloatCurveKey", {
	read = function(stream)
		local t = stream:readf32()
		local v = stream:readf32()
		local interpolation = Enum.KeyInterpolationMode:FromValue(stream:readu16()) :: Enum.KeyInterpolationMode
		local ck = FloatCurveKey.new(t, v, interpolation)

		-- tangent props are typed as number, but they should be number?
		ck.LeftTangent = readTangent(stream, 1) :: number
		ck.RightTangent = readTangent(stream, 2) :: number

		return ck
	end,
	write = function(stream, ck)
		stream:writef32(ck.Time)
		stream:writef32(ck.Value)
		stream:writeu16(ck.Interpolation.Value)

		if ck.LeftTangent then
			stream:writeu8(1)
			stream:writef32(ck.LeftTangent)
		else
			stream:writeu8(0)
		end

		if ck.RightTangent then
			stream:writeu8(2)
			stream:writef32(ck.RightTangent)
		else
			stream:writeu8(0)
		end
	end,
})
