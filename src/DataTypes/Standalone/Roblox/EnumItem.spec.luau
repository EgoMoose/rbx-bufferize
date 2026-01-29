local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES: { EnumItem } = {
	Enum.Material.Carpet,
	Enum.ControlMode.MouseLockSwitch,
	Enum.RaycastFilterType.Exclude,
	Enum.AnimationPriority.Movement,
}

TestHelper.dataType(require(script.Parent.EnumItem), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
