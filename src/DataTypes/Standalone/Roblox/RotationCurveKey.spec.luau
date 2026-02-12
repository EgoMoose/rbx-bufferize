local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local CFrameStream = require(script:FindFirstAncestor("DataTypes").Helpers.CFrameStream)

local VALUES = {
	RotationCurveKey.new(0, CFrame.Angles(1, 2, 3), Enum.KeyInterpolationMode.Cubic),
	RotationCurveKey.new(math.pi, CFrame.Angles(math.pi, 0, -math.pi / 2), Enum.KeyInterpolationMode.Constant),
	RotationCurveKey.new(1, CFrame.identity, Enum.KeyInterpolationMode.Linear),
}

TestHelper.dataType(require(script.Parent.RotationCurveKey), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		local aCF = a.Value
		local bCF = b.Value
		a.Value = CFrame.identity
		b.Value = CFrame.identity
		return a == b and CFrameStream.equals(aCF, bCF)
	end,
})
