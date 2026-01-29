-- there are a few data types that need to read / write CFrames
-- for these cases it's helpful to have a module that that can be
-- required by other definitions

local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local BufferStream = require(dataTypesRoot.Parent.BufferStream)

local F32_EPSILON = math.pow(2, -23)

local function sanitizeCF(cframe: CFrame)
	local matrix = { select(4, cframe:GetComponents()) }
	for i = 1, 3 do
		local x = matrix[i + 0]
		local y = matrix[i + 3]
		local z = matrix[i + 6]
		-- check if the magnitude of the vector is 1
		if 1 - (x * x + y * y + z * z) <= F32_EPSILON then
			local absX = math.abs(x)
			local absY = math.abs(y)
			local absZ = math.abs(z)
			-- check that one of the individual components is 1
			if 1 - math.max(absX, absY, absZ) <= F32_EPSILON then
				matrix[i + 0] = math.round(x)
				matrix[i + 3] = math.round(y)
				matrix[i + 6] = math.round(z)
				continue
			end
		end
		return false, cframe
	end
	return true, CFrame.new(cframe.X, cframe.Y, cframe.Z, table.unpack(matrix, 1, 9))
end

local function u32Rotation(sanitizedCF: CFrame)
	local m11, m12, m13, m21, m22, m23, m31, m32, m33 = select(4, sanitizedCF:GetComponents())
	local r1 = math.max(m11 + m12 + m13, 0)
	local r2 = math.max(m21 + m22 + m23, 0)
	local r3 = math.max(m31 + m32 + m33, 0)
	-- stylua: ignore
	return tonumber(table.concat({
		r1, math.abs(m11), math.abs(m12), math.abs(m13),
		r2, math.abs(m21), math.abs(m22), math.abs(m23),
		r3, math.abs(m31), math.abs(m32), math.abs(m33),
	}, ""), 2) :: number
end

local function generateRotationLookups(rotations: { CFrame })
	local byIndex = {}
	local byU32 = {}
	for i, rotation in rotations do
		local success, sanitizedCF = sanitizeCF(rotation.Rotation)
		assert(success, "Tried to sanitize the rotation matrix of a complex CFrame.")
		local rotation32 = u32Rotation(sanitizedCF)
		byIndex[i] = sanitizedCF
		byU32[rotation32] = i
	end

	return {
		byIndex = byIndex,
		byU32 = byU32,
	}
end

local function rotationYXZ(degX: number, degY: number, degZ: number)
	return CFrame.fromEulerAngles(math.rad(degX), math.rad(degY), math.rad(degZ), Enum.RotationOrder.YXZ)
end

local ROTATION_LOOKUP = generateRotationLookups({
	rotationYXZ(0, 0, 0),
	rotationYXZ(90, 0, 0),
	rotationYXZ(0, 180, 180),
	rotationYXZ(-90, 0, 0),
	rotationYXZ(0, 180, 90),
	rotationYXZ(0, 90, 90),
	rotationYXZ(0, 0, 90),
	rotationYXZ(0, -90, 90),
	rotationYXZ(-90, -90, 0),
	rotationYXZ(0, -90, 0),
	rotationYXZ(90, -90, 0),
	rotationYXZ(0, 90, 180),
	rotationYXZ(0, 180, 0),
	rotationYXZ(-90, -180, 0),
	rotationYXZ(0, 0, 180),
	rotationYXZ(90, 180, 0),
	rotationYXZ(0, 0, -90),
	rotationYXZ(0, -90, -90),
	rotationYXZ(0, -180, -90),
	rotationYXZ(0, 90, -90),
	rotationYXZ(90, 90, 0),
	rotationYXZ(0, 90, 0),
	rotationYXZ(-90, 90, 0),
	rotationYXZ(0, -90, 180),
})

local function read(stream: BufferStream.BufferStream)
	local index = stream:readu8()
	if index > 0 then
		local rotation = ROTATION_LOOKUP.byIndex[index]
		return CFrame.new(stream:readf32(), stream:readf32(), stream:readf32()) * rotation
	else
		local components = {}
		for i = 1, 12 do
			components[i] = stream:readf32()
		end
		return CFrame.new(table.unpack(components, 1, 12))
	end
end

local function write(stream: BufferStream.BufferStream, cframe: CFrame)
	local success, sanitizedCF = sanitizeCF(cframe)

	if success then
		local rotation32 = u32Rotation(sanitizedCF)
		local rotationIndex = ROTATION_LOOKUP.byU32[rotation32]

		stream:writeu8(rotationIndex)
		stream:writef32(cframe.X)
		stream:writef32(cframe.Y)
		stream:writef32(cframe.Z)
	else
		stream:writeu8(0)
		for _, component in { cframe:GetComponents() } do
			stream:writef32(component)
		end
	end
end

local function equals(a: CFrame, b: CFrame)
	local componentsA = { a:GetComponents() }
	local componentsB = { b:GetComponents() }

	for i = 1, 3 do
		if componentsA[i] ~= componentsB[i] then
			return false
		end
	end

	for i = 4, 12 do
		if math.abs(componentsA[i] - componentsB[i]) > F32_EPSILON then
			return false
		end
	end

	return true
end

return {
	read = read,
	write = write,
	equals = equals,
}
