local DataTypePacker = require(script.DataTypePacker)
local UserdataDefinitions = require(script.Standalone.Userdata.Definitions)

return {
	Userdata = UserdataDefinitions,
	Encoder = DataTypePacker.new({
		require(script.Standalone),
		require(script.Dependant),
	}),
}
