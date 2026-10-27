local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

-- UnixTimestampMillis is an integer between these bounds (years 1400 to 9999)
-- offset from the minimum the range fits within an unsigned 48 bit integer
-- i48 can't be used directly since the max (~2.53e14) exceeds its range (~1.4e14)
local MIN_MILLIS = -17987443200000

return DataTypeDefinition.new("DateTime", {
	read = function(stream)
		return DateTime.fromUnixTimestampMillis(stream:readu48() + MIN_MILLIS)
	end,
	write = function(stream, dateTime)
		stream:writeu48(dateTime.UnixTimestampMillis - MIN_MILLIS)
	end,
})
