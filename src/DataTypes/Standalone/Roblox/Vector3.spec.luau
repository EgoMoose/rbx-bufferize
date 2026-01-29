local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Vector3.new(1, 2, 3),
	Vector3.new(-1, -2, -3),
	Vector3.new(math.pi, math.exp(1), math.sqrt(2)),
}

TestHelper.dataType(require(script.Parent.Vector3), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
