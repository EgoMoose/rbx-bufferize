local pkgRoot = game.ReplicatedStorage.Packages.Bufferize
local dataTypes = require(pkgRoot.DataTypes)

local definitionsByTypeId = dataTypes.Encoder.definitionsByTypeId

local KEYWORDS = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

local function toPropertyKey(typeOf: string)
	if typeOf:match("^[%a_][%w_]*$") and not KEYWORDS[typeOf] then
		return typeOf
	end
	return `["{typeOf}"]`
end

local maxTypeId = -1
for _, definition in definitionsByTypeId do
	maxTypeId = math.max(definition.typeId, maxTypeId)
end

local supportedTypings = {}
local overridableTypings = {}
local readerTypings = {}
local writerTypings = {}
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

		local key = toPropertyKey(definition.typeOf)
		local inlineTyping = definition.typing:gsub("%s*\n%s*", " ")
		table.insert(readerTypings, `{key}: (b: buffer, offset: number) -> ({inlineTyping}, number),`)
		table.insert(writerTypings, `{key}: (b: buffer, offset: number, value: {inlineTyping}) -> (buffer, number),`)
	end
end

print("export type Supported = " .. table.concat(supportedTypings, "\n\t| "))
print("")
print("export type Overridable = " .. table.concat(overridableTypings, "\n\t| "))
print("")
print("export type Readers = {\n\t" .. table.concat(readerTypings, "\n\t") .. "\n}")
print("")
print("export type Writers = {\n\t" .. table.concat(writerTypings, "\n\t") .. "\n}")
print("")
print("return {}")

return {}
