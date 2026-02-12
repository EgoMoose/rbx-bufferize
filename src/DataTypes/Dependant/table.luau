local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local BufferStream = require(dataTypesRoot.Parent.BufferStream)
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)
local StandaloneDataTypes = require(dataTypesRoot.Standalone)

type BufferStream = BufferStream.BufferStream

local tbl_u8TypeId = 1
local tbl_u16TypeId = 2
local tbl_u32TypeId = 3

-- these pointers are not the same as the userdata:pointer type
-- they serve a similar purpose, but are used and recognized
-- explicitly by tables
local pointer_u8TypeId = 4
local pointer_u16TypeId = 5
local pointer_u32TypeId = 6

local arr_u8TypeId = 7
local arr_u16TypeId = 8
local arr_u32TypeId = 9
local dict_u8TypeId = 10
local dict_u16TypeId = 11
local dict_u32TypeId = 12

local internalTypeId = 13
local standaloneTypeId = 14

local function createUnsignedReadWrite(u8TypeId: number, u16TypeId: number, u32TypeId: number)
	local reader = DataTypeDefinition.createReader({
		[u8TypeId] = function(stream)
			return stream:readu8()
		end,
		[u16TypeId] = function(stream)
			return stream:readu16()
		end,
		[u32TypeId] = function(stream)
			return stream:readu32()
		end,
	})

	local function writer(stream: BufferStream, unsigned: number)
		if unsigned <= 0xFF then
			stream:writeu8(u8TypeId)
			stream:writeu8(unsigned)
		elseif unsigned <= 0xFFFF then
			stream:writeu8(u16TypeId)
			stream:writeu16(unsigned)
		else
			stream:writeu8(u32TypeId)
			stream:writeu32(unsigned)
		end
	end

	local function isKind(stream: BufferStream)
		local prevCursor = stream.cursor
		local id = stream:readu8()
		stream.cursor = prevCursor
		return id == u8TypeId or id == u16TypeId or id == u32TypeId
	end

	return {
		isKind = isKind,
		read = reader,
		write = writer,
	}
end

local tblReadWrite = createUnsignedReadWrite(tbl_u8TypeId, tbl_u16TypeId, tbl_u32TypeId)
local pointerReadWrite = createUnsignedReadWrite(pointer_u8TypeId, pointer_u16TypeId, pointer_u32TypeId)
local arrReadWrite = createUnsignedReadWrite(arr_u8TypeId, arr_u16TypeId, arr_u32TypeId)
local dictReadWrite = createUnsignedReadWrite(dict_u8TypeId, dict_u16TypeId, dict_u32TypeId)

local function readDeepTblStream(stream: BufferStream)
	local count = tblReadWrite.read(stream)

	local udByPointerIndex = {}
	local pointerIndexByUd = {}
	for i = 1, count do
		local ud = newproxy(false)
		udByPointerIndex[i] = ud
		pointerIndexByUd[ud] = i
	end

	local tblArr: { { [any]: any } } = {}
	for i = 1, count do
		local isArray = arrReadWrite.isKind(stream)
		local keyCount = if isArray then arrReadWrite.read(stream) else dictReadWrite.read(stream)

		local arr = {}
		for j = 1, keyCount do
			local id = stream:readu8()
			local isInternal = id == internalTypeId
			if isInternal and pointerReadWrite.isKind(stream) then
				local pointerIndex = pointerReadWrite.read(stream)
				arr[j] = udByPointerIndex[pointerIndex]
			else
				arr[j] = StandaloneDataTypes:readStream(stream)
			end
		end

		if isArray then
			tblArr[i] = arr
		else
			local dict = {}
			for j = 1, keyCount do
				local isInternal = stream:readu8() == internalTypeId
				if isInternal and pointerReadWrite.isKind(stream) then
					local pointerIndex = pointerReadWrite.read(stream)
					dict[udByPointerIndex[pointerIndex]] = arr[j]
				else
					dict[StandaloneDataTypes:readStream(stream)] = arr[j]
				end
			end
			tblArr[i] = dict
		end
	end

	for _, tbl in tblArr do
		for key, value in tbl do
			local newKey = key
			local keyIndex = pointerIndexByUd[key]
			if keyIndex then
				newKey = tblArr[keyIndex]
			end

			local newValue = value
			local valueIndex = pointerIndexByUd[value]
			if valueIndex then
				newValue = tblArr[valueIndex]
			end

			tbl[key] = nil
			tbl[newKey] = newValue
		end
	end

	return tblArr[1]
end

local function getUniqueTblsArray(rootTbl: { [any]: any })
	local i = 1
	local uniqueArr = { rootTbl }

	local visited = {}
	local inArray = { [rootTbl] = true }

	while uniqueArr[i] do
		visited[uniqueArr[i]] = true

		for key, value in uniqueArr[i] do
			if typeof(key) == "table" and not inArray[key] then
				inArray[key] = true
				table.insert(uniqueArr, key)
			end
			if typeof(value) == "table" and not inArray[value] then
				inArray[value] = true
				table.insert(uniqueArr, value)
			end
		end

		while visited[uniqueArr[i + 1]] do
			i = i + 1
		end
		i = i + 1
	end

	return uniqueArr
end

local function writeDeepTblStream(stream: BufferStream, rootTbl: { [any]: any })
	local uniqueTblsArr = getUniqueTblsArray(rootTbl)

	local pointerCount = 0
	local pointerIndexByTbl = {}
	for _, tbl in uniqueTblsArr do
		pointerCount = pointerCount + 1
		pointerIndexByTbl[tbl] = pointerCount
	end

	local length = #uniqueTblsArr
	tblReadWrite.write(stream, length)

	for j = 1, length do
		local tbl = uniqueTblsArr[j]
		local keyStream = BufferStream.new(buffer.create(0))
		local valueStream = BufferStream.new(buffer.create(0))

		local keyCount = 0
		local isArray = true
		for key, value in tbl do
			keyCount = keyCount + 1

			local keyTypeOf = typeof(key)
			if keyTypeOf == "table" then
				local pointerIndex = pointerIndexByTbl[key]
				keyStream:writeu8(internalTypeId)
				pointerReadWrite.write(keyStream, pointerIndex)
			else
				-- stylua: ignore
				if isArray and not (keyTypeOf == "number" and key % 1 == 0 and key >= 1 and tbl[math.max(1, key - 1)] ~= nil) then
					isArray = false
				end
				keyStream:writeu8(standaloneTypeId)
				StandaloneDataTypes:writeStream(keyStream, key)
			end

			if typeof(value) == "table" then
				local pointerIndex = pointerIndexByTbl[value]
				valueStream:writeu8(internalTypeId)
				pointerReadWrite.write(valueStream, pointerIndex)
			else
				valueStream:writeu8(standaloneTypeId)
				StandaloneDataTypes:writeStream(valueStream, value)
			end
		end

		local tblStream = BufferStream.new(buffer.create(0))
		if isArray then
			arrReadWrite.write(tblStream, keyCount)
			tblStream:writeBuffer(valueStream.b)
		else
			dictReadWrite.write(tblStream, keyCount)
			tblStream:writeBuffer(valueStream.b)
			tblStream:writeBuffer(keyStream.b)
		end

		stream:writeBuffer(tblStream.b)
	end
end

local tblDefinition = DataTypeDefinition.new("table", {
	read = readDeepTblStream,
	write = writeDeepTblStream,
})

tblDefinition.overridable = false
tblDefinition.typing = "{ [any]: any }"

return tblDefinition
