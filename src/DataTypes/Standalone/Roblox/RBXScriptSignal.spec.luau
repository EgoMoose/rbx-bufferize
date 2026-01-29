local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	workspace.AncestryChanged,
}

TestHelper.dataType(require(script.Parent.RBXScriptSignal), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
