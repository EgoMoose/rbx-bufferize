local TypeUnions = require(script.TypeUnions)
local DataTypePacker = require(script.DataTypePacker)
local UserdataDefinitions = require(script.Standalone.Userdata.Definitions)

export type Supported = TypeUnions.Supported
export type Overridable = TypeUnions.Overridable
export type Readers = TypeUnions.Readers
export type Writers = TypeUnions.Writers

local Encoder = DataTypePacker.new({
	require(script.Standalone),
	require(script.Dependant),
})

local readers = {}
local writers = {}
for typeOf, definition: any in Encoder.definitionsByTypeOf do
	if definition.support ~= "implemented" or typeOf:match("userdata:") then
		continue
	end

	readers[typeOf] = function(b: buffer, offset: number)
		return definition:readRaw(b, offset)
	end

	writers[typeOf] = function(b: buffer, offset: number, value: any)
		return definition:writeRaw(b, offset, value)
	end
end

return {
	Userdata = UserdataDefinitions,
	Encoder = Encoder,
	Readers = (table.freeze(readers) :: any) :: Readers,
	Writers = (table.freeze(writers) :: any) :: Writers,
}
