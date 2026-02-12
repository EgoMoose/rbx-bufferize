local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	newproxy(false),
}

TestHelper.dataType(require(script.Parent.userdata), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
