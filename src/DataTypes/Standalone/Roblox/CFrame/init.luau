local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)
local CFrameStream = require(script.CFrameStream)

return DataTypeDefinition.new("CFrame", {
	read = CFrameStream.read,
	write = CFrameStream.write,
})
