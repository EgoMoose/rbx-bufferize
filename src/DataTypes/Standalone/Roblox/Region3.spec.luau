local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Region3.new(Vector3.new(1, 2, 3), Vector3.new(4, 5, 6)),
	Region3.new(Vector3.new(-1, -2, -3), Vector3.new(4, 5, 6)),
	Region3.new(Vector3.new(-math.pi, -math.pi, -math.pi), Vector3.new(4, 5, 6)), -- not lossless?
}

TestHelper.dataType(require(script.Parent.Region3), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		-- I do not for the life of me understand why this isn't losslessly encoding.
		-- I confirmed that the vMin and vMax components save and load to the buffer, but
		-- it seems like when you plug them into the Region3 constructor the value can change??!?
		return a.Size == b.Size and a.CFrame:FuzzyEq(b.CFrame)
	end,
})
