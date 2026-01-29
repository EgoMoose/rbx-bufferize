local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Random.new(),
}

TestHelper.dataType(require(script.Parent.Random), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
