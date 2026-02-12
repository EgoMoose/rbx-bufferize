local userdataRoot = script:FindFirstAncestor("Userdata")
local UserdataDefinition = require(userdataRoot.UserdataDefinition)

return UserdataDefinition.new("deduplication-pointer", function(index: number)
	return { index = index }
end)
