local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Vector2int16.new(1, 2),
	Vector2int16.new(-1, -2),
	Vector2int16.new(10 + math.pi, -70 + math.exp(1)),
}

TestHelper.dataType(require(script.Parent.Vector2int16), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
