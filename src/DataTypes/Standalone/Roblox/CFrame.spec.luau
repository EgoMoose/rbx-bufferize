local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local CFrameStream = require(script:FindFirstAncestor("DataTypes").Helpers.CFrameStream)

local VALUES = {
	CFrame.identity,
	CFrame.Angles(math.pi, 0, -math.pi / 2),
	CFrame.new(0, 0, 0, 1, 2, 3, 4),
}

TestHelper.dataType(require(script.Parent.CFrame), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		--[[
		WAIT! That's not lossless?!?!

		CFrame's that are aligned to the cardinal axes are stored as a single byte.
		The concept is described here: https://dom.rojo.space/binary.html#cframe
		However, b/c of floating point math the components of this type of cframe
		often doesn't get stored perfectly as -1, 0, or 1. Thus, we sanitize the value
		within range of f32 epsilon error before encoding it.

		This means that the in the case of these aligned CFrames you might not get a lossless
		encoding, but that's b/c you're actually getting a **MORE** accurate result than what's
		being input.
		--]]
		return CFrameStream.equals(a, b)
	end,
})
