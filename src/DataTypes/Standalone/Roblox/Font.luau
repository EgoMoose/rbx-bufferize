local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Font", {
	read = function(stream)
		local weight = Enum.FontWeight:FromValue(stream:readu16()) :: Enum.FontWeight
		local style = Enum.FontStyle:FromValue(stream:readu16()) :: Enum.FontStyle

		local length = stream:readu8()
		if length == 0 then
			-- font id case
			local fontId = stream:readu32()
			return Font.fromId(fontId, weight, style)
		else
			-- family name case
			local familyName = stream:readString(length - 1)
			if familyName == "" then
				-- Enum.Font.Arial is the first font and maps to Arimo
				familyName = "Arimo"
			end
			return Font.fromName(familyName, weight, style)
		end
	end,
	write = function(stream, font)
		local family = font.Family
		local fontId = family:match("%d+$")

		stream:writeu16(font.Weight.Value)
		stream:writeu16(font.Style.Value)

		if fontId then
			stream:writeu8(0)
			stream:writeu32(tonumber(fontId) :: number)
		else
			local familyName = family:match("/(%w+).json$") or ""
			local length = #familyName

			-- we store the length as length + 1 since we're using this byte both for
			-- the length of the string, but also to identify if it's storing a font id or not
			assert(length <= 254, `Family name cannot exceed 254 characters: '{familyName}'`)
			stream:writeu8(length + 1)
			stream:writeString(familyName, length)
		end
	end,
})
