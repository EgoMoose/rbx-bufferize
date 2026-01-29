local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Font.fromEnum(Enum.Font.Bangers),
	Font.fromName("Creepster", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
}

TestHelper.dataType(require(script.Parent.Font), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
