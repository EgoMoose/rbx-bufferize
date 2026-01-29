local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	vector.create(1, 2, 3),
	vector.create(-1, -2, -3),
	vector.create(math.pi, math.exp(1), math.sqrt(2)),
}

TestHelper.dataType(require(script.Parent.vector), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
