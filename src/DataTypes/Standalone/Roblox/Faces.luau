local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local FACE_NAME_ORDER = { "Front", "Bottom", "Left", "Back", "Top", "Right" }

return DataTypeDefinition.new("Faces", {
	read = function(stream)
		local index = stream:readu8()
		local enums: { Enum.NormalId } = {}
		for i, faceName in FACE_NAME_ORDER do
			if bit32.band(index, bit32.lshift(1, (i - 1))) > 0 then
				table.insert(enums, (Enum.NormalId :: any)[faceName])
			end
		end
		return Faces.new(table.unpack(enums))
	end,
	write = function(stream, faces)
		local index = 0
		for i, faceName in FACE_NAME_ORDER do
			if (faces :: any)[faceName] then
				index = bit32.bor(index, bit32.lshift(1, (i - 1)))
			end
		end
		stream:writeu8(index)
	end,
})
