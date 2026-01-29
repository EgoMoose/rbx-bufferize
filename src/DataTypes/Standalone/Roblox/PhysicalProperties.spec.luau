local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	PhysicalProperties.new(Enum.Material.Brick),
	PhysicalProperties.new(Enum.Material.Concrete),
	PhysicalProperties.new(0.2, 0.4, 0.6, 10, 4),
}

TestHelper.dataType(require(script.Parent.PhysicalProperties), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
