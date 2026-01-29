local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Rect.new(),
	Rect.new(0, 0, 12.5, math.pi),
	Rect.new(Vector2.new(-10, -10), Vector2.new(10, math.pi)),
}

TestHelper.dataType(require(script.Parent.Rect), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
