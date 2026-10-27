-- there are a few data types that need to read / write CFrames
-- for these cases it's helpful to have a module that that can be
-- required by other definitions

local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local BufferStream = require(dataTypesRoot.Parent.BufferStream)

local F32_EPSILON = math.pow(2, -23)
local AXES = { Vector3.xAxis, Vector3.yAxis, Vector3.zAxis }

local function findAxis(x: number, y: number, z: number)
	local axis = math.abs(y) * 1 + math.abs(z) * 2
	return axis, math.max(0, -(x + y + z))
end

local function rotationToIndex(sanitizedCF: CFrame)
	local _, _, _, m11, m12, m13, m21, m22, m23, m31, m32, m33 = sanitizedCF:GetComponents()

	local v1 = Vector3.new(m11, m12, m13)
	local v2 = Vector3.new(m21, m22, m23)
	local v3 = Vector3.new(m31, m32, m33)
	if v1:Cross(v2) ~= v3 then
		return nil :: number?
	end

	local c1, n1 = findAxis(m11, m12, m13)
	local c2, n2 = findAxis(m21, m22, m23)
	local c2Reduced = if c2 < c1 then c2 else c2 - 1
	return c1 * 8 + c2Reduced * 4 + n1 * 2 + n2 + 1
end

local function indexToRotation(index: number)
	local i = index - 1
	local c1 = i // 8
	local c2Reduced = (i // 4) % 2
	local c2 = if c2Reduced < c1 then c2Reduced else c2Reduced + 1

	local r1 = AXES[c1 + 1] * (1 - ((i // 2) % 2) * 2)
	local r2 = AXES[c2 + 1] * (1 - (i % 2) * 2)
	local r3 = r1:Cross(r2)

	-- stylua: ignore
	return CFrame.new(
		0, 0, 0,
		r1.X, r1.Y, r1.Z,
		r2.X, r2.Y, r2.Z,
		r3.X, r3.Y, r3.Z
	)
end

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

local function read(stream: BufferStream.BufferStream)
	local index = stream:readu8()
	if index > 0 then
		return CFrame.new(stream:readf32(), stream:readf32(), stream:readf32()) * indexToRotation(index)
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
	local rotationIndex = if success then rotationToIndex(sanitizedCF) else nil

	if rotationIndex then
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
