local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {}

TestHelper.dataType(require(script.Parent.Secret), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
