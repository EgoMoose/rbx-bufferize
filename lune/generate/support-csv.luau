local pkgRoot = game.ReplicatedStorage.Packages.Bufferize
local dataTypes = require(pkgRoot.DataTypes)

-- https://tableconvert.com/csv-to-markdown

local SUPPORT_MAP = {
	["implemented"] = "✔",
	["unimplemented"] = "❌",
	["never"] = "⛔",
}

local lines = { "DataType, Supported, Overridable" }
local definitionsByTypeId = dataTypes.Encoder.definitionsByTypeId

local maxTypeId = -1
for _, definition in definitionsByTypeId do
	maxTypeId = math.max(definition.typeId, maxTypeId)
end

for i = 0, maxTypeId do
	local definition = definitionsByTypeId[i]
	if definition.typeOf:match("userdata:") then
		continue
	end

	table.insert(
		lines,
		table.concat({
			definition.typeOf,
			SUPPORT_MAP[definition.support],
			if definition.overridable
				then SUPPORT_MAP.implemented
				elseif definition.support == "never" then SUPPORT_MAP.never
				else SUPPORT_MAP.unimplemented,
		}, ",")
	)
end

print(table.concat(lines, "\n"))

return {}
