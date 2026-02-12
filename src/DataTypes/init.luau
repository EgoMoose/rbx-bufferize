local TypeUnions = require(script.TypeUnions)
local DataTypePacker = require(script.DataTypePacker)
local UserdataDefinitions = require(script.Standalone.Userdata.Definitions)

export type Supported = TypeUnions.Supported
export type Overridable = TypeUnions.Overridable

return {
	Userdata = UserdataDefinitions,
	Encoder = DataTypePacker.new({
		require(script.Standalone),
		require(script.Dependant),
	}),
}
