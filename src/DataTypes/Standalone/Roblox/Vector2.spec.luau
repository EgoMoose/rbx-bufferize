local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Vector2.new(1, 2),
	Vector2.new(-1, -2),
	Vector2.new(math.pi, math.exp(1)),
}

TestHelper.dataType(require(script.Parent.Vector2), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
