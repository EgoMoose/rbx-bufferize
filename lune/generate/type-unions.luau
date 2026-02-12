local pkgRoot = game.ReplicatedStorage.Packages.Bufferize
local dataTypes = require(pkgRoot.DataTypes)

local definitionsByTypeId = dataTypes.Encoder.definitionsByTypeId

local maxTypeId = -1
for _, definition in definitionsByTypeId do
	maxTypeId = math.max(definition.typeId, maxTypeId)
end

local supportedTypings = {}
local overridableTypings = {}
for i = 0, maxTypeId do
	local definition = definitionsByTypeId[i]
	if definition.typeOf:match("userdata:") then
		continue
	end

	if definition.support == "implemented" then
		table.insert(supportedTypings, definition.typing)
		if definition.overridable then
			table.insert(overridableTypings, definition.typing)
		end
	end
end

print("export type Supported = " .. table.concat(supportedTypings, "\n\t| "))
print("")
print("export type Overridable = " .. table.concat(overridableTypings, "\n\t| "))
print("")
print("return {}")

return {}
