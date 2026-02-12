local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local pointer = require(script.Parent.Parent.Definitions.DeduplicationPointer)

local VALUES = {
	pointer:create(10),
	pointer:create(1000),
	pointer:create(100000000000),
}

TestHelper.dataType(require(script.Parent.DeduplicationPointer), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(udA, udB)
		local a = pointer:read(udA)
		local b = pointer:read(udB)
		return a.index == b.index
	end,
})
