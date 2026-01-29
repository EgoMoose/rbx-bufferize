local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	OverlapParams.new(),
}

TestHelper.dataType(require(script.Parent.OverlapParams), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
