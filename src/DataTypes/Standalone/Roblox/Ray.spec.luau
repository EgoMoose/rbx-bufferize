local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Ray.new(Vector3.new(1, 2, 3), Vector3.new(100, 0, 0)),
	Ray.new(Vector3.new(math.pi, 2, -109090), Vector3.new(1, -1, 1).Unit),
	Ray.new(Vector3.new(-0.1, -0.2, 0.3), Vector3.new(-1, 0, 1).Unit),
}

TestHelper.dataType(require(script.Parent.Ray), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
