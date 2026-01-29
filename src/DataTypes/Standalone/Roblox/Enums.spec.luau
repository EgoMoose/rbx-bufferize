local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Enum,
}

TestHelper.dataType(require(script.Parent.Enums), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
