local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	RaycastParams.new(),
}

TestHelper.dataType(require(script.Parent.RaycastParams), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
