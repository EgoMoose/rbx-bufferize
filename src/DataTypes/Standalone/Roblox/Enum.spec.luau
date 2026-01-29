local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES: { Enum } = {
	Enum.Material,
	Enum.ControlMode,
	Enum.RaycastFilterType,
	Enum.ExplosionType,
}

TestHelper.dataType(require(script.Parent.Enum), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
