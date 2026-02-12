local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local BufferStream = require(dataTypesRoot.Parent.BufferStream)
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)
local StandaloneDataTypes = require(dataTypesRoot.Standalone)
local TableHelper = require(dataTypesRoot.Helpers.TableHelper)

type BufferStream = BufferStream.BufferStream

local tbl_u8TypeId = 1
local tbl_u16TypeId = 2
local tbl_u32TypeId = 3

local tblRef_u8TypeId = 4
local tblRef_u16TypeId = 5
local tblRef_u32TypeId = 6

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
local tblRefReadWrite = createUnsignedReadWrite(tblRef_u8TypeId, tblRef_u16TypeId, tblRef_u32TypeId)
local arrReadWrite = createUnsignedReadWrite(arr_u8TypeId, arr_u16TypeId, arr_u32TypeId)
local dictReadWrite = createUnsignedReadWrite(dict_u8TypeId, dict_u16TypeId, dict_u32TypeId)

local function readDeepTblStream(stream: BufferStream)
	local nUniqueTbls = tblReadWrite.read(stream)

	local uniqueTblsArr: { { [any]: any } } = {}
	for i = 1, nUniqueTbls do
		uniqueTblsArr[i] = {}
	end

	local function readStep()
		local id = stream:readu8()
		if id == internalTypeId and tblRefReadWrite.isKind(stream) then
			local tblRefIndex = tblRefReadWrite.read(stream)
			return uniqueTblsArr[tblRefIndex]
		else
			return StandaloneDataTypes:readStream(stream)
		end
	end

	for i = 1, nUniqueTbls do
		local tbl = uniqueTblsArr[i]
		local isArray = arrReadWrite.isKind(stream)
		local keyCount = if isArray then arrReadWrite.read(stream) else dictReadWrite.read(stream)

		if isArray then
			for j = 1, keyCount do
				tbl[j] = readStep()
			end
		else
			local values = {}
			for j = 1, keyCount do
				values[j] = readStep()
			end

			local keys = {}
			for j = 1, keyCount do
				keys[j] = readStep()
			end

			for j = 1, keyCount do
				tbl[keys[j]] = values[j]
			end
		end
	end

	return uniqueTblsArr[1]
end

local function writeDeepTblStream(stream: BufferStream, rootTbl: { [any]: any })
	local uniqueTblsArr = TableHelper.getUniqueTblsArray(rootTbl)

	local tblRefIndexByTbl = {}
	for i, tbl in uniqueTblsArr do
		tblRefIndexByTbl[tbl] = i
	end

	tblReadWrite.write(stream, #uniqueTblsArr)

	for _, tbl in uniqueTblsArr do
		local keyStream = BufferStream.new(buffer.create(0))
		local valueStream = BufferStream.new(buffer.create(0))

		local keyCount = 0
		local isArray = true
		for key, value in tbl do
			keyCount = keyCount + 1

			local keyTypeOf = typeof(key)
			if keyTypeOf == "table" then
				local tblRefIndex = tblRefIndexByTbl[key]
				keyStream:writeu8(internalTypeId)
				tblRefReadWrite.write(keyStream, tblRefIndex)
			else
				-- stylua: ignore
				if isArray and not (keyTypeOf == "number" and key % 1 == 0 and key >= 1 and tbl[math.max(1, key - 1)] ~= nil) then
					isArray = false
				end
				keyStream:writeu8(standaloneTypeId)
				StandaloneDataTypes:writeStream(keyStream, key)
			end

			if typeof(value) == "table" then
				local tblRefIndex = tblRefIndexByTbl[value]
				valueStream:writeu8(internalTypeId)
				tblRefReadWrite.write(valueStream, tblRefIndex)
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
tblDefinition.typing = "{ any }\n\t| { [any]: any }"

return tblDefinition
