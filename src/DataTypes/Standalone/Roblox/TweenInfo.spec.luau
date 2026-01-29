local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	TweenInfo.new(),
	TweenInfo.new(0, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true, 10.2765),
}

TestHelper.dataType(require(script.Parent.TweenInfo), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
