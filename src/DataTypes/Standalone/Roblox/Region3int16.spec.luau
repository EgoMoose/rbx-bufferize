local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Region3int16.new(Vector3int16.new(1, 2, 3), Vector3int16.new(4, 5, 6)),
	Region3int16.new(Vector3int16.new(-1, -2, -3), Vector3int16.new(4, 5, 6)),
}

TestHelper.dataType(require(script.Parent.Region3int16), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
