local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local userdefined = require(script.Parent.Parent.Definitions.Userdefined)

local VALUES = {
	userdefined:create("kindA", buffer.fromstring("Hello world!")),
	userdefined:create("kindB", buffer.fromstring("skjzhdaknk")),
	userdefined:create("kindC", buffer.fromstring("1282y8218nsndkj,a")),
}

TestHelper.dataType(require(script.Parent.Userdefined), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(udA, udB)
		local a = userdefined:read(udA)
		local b = userdefined:read(udB)
		return a.kind == b.kind and buffer.tostring(a.b) == buffer.tostring(b.b)
	end,
})
