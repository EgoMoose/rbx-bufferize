local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local AXIS_NAME_ORDER = { "X", "Y", "Z" }

return DataTypeDefinition.new("Axes", {
	read = function(stream)
		local index = stream:readu8()
		local enums: { Enum.Axis } = {}
		for i, axisName in AXIS_NAME_ORDER do
			if bit32.band(index, bit32.lshift(1, (i - 1))) > 0 then
				table.insert(enums, (Enum.Axis :: any)[axisName])
			end
		end
		return Axes.new(table.unpack(enums))
	end,
	write = function(stream, axes)
		local index = 0
		for i, axisName in AXIS_NAME_ORDER do
			if (axes :: any)[axisName] then
				index = bit32.bor(index, bit32.lshift(1, (i - 1)))
			end
		end
		stream:writeu8(index)
	end,
})
