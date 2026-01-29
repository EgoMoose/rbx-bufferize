local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Vector3int16.new(1, 2, 3),
	Vector3int16.new(-1, -2, -3),
	Vector3int16.new(10 + math.pi, 70 + math.exp(1), -33 + math.sqrt(2)),
}

TestHelper.dataType(require(script.Parent.Vector3int16), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
