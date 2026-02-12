local userdataRoot = script:FindFirstAncestor("Userdata")
local UserdataDefinition = require(userdataRoot.UserdataDefinition)

return UserdataDefinition.new("instance-pointer", function(index: number)
	return { index = index }
end)
