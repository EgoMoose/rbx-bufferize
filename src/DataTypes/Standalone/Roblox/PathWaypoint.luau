local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local label_u8 = 1
local label_u16 = 2
local label_u32 = 3

local labelReader = DataTypeDefinition.createReader({
	[label_u8] = function(stream)
		return stream:readString(stream:readu8())
	end,
	[label_u16] = function(stream)
		return stream:readString(stream:readu8())
	end,
	[label_u32] = function(stream)
		return stream:readString(stream:readu8())
	end,
})

return DataTypeDefinition.new("PathWaypoint", {
	read = function(stream)
		local position = Vector3.new(stream:readf32(), stream:readf32(), stream:readf32())
		local action = Enum.PathWaypointAction:FromValue(stream:readu16()) :: Enum.PathWaypointAction
		local label = labelReader(stream)
		return PathWaypoint.new(position, action, label)
	end,
	write = function(stream, wp)
		stream:writef32(wp.Position.X)
		stream:writef32(wp.Position.Y)
		stream:writef32(wp.Position.Z)
		stream:writeu16(wp.Action.Value)

		local label = wp.Label
		local length = #label
		if length <= 0xFF then
			stream:writeu8(label_u8)
			stream:writeu8(length)
		elseif length <= 0xFFFF then
			stream:writeu8(label_u16)
			stream:writeu16(length)
		else
			stream:writeu8(label_u32)
			stream:writeu32(length)
		end

		stream:writeString(label, length)
	end,
})
