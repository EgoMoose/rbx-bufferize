local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES: { (...any) -> ...any } = {
	function() end,
	table.clone,
	setmetatable,
}

TestHelper.dataType(require(script.Parent["function"]), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
