local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local CFrameStream = require(dataTypesRoot.Helpers.CFrameStream)
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("CFrame", {
	read = CFrameStream.read,
	write = CFrameStream.write,
})
