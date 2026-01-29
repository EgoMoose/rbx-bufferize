local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	workspace.AncestryChanged:Connect(function() end),
}

TestHelper.dataType(require(script.Parent.RBXScriptConnection), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
