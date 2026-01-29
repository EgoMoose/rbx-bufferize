local userdataRoot = script:FindFirstAncestor("Userdata")
local UserdataDefinition = require(userdataRoot.UserdataDefinition)

return UserdataDefinition.new("userdefined", function(kind: string, b: buffer)
	return {
		kind = kind,
		b = b,
	}
end)
