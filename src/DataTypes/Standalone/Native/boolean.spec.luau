local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	true,
	false,
}

TestHelper.dataType(require(script.Parent.boolean), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
