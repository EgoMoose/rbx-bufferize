local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local userdataRoot = script:FindFirstAncestor("Userdata")
local UserdataDefinitions = require(userdataRoot.Definitions)
local userdataDefinition = UserdataDefinitions.Userdefined

local kind_u8 = 1
local kind_u16 = 2
local kind_u32 = 3

local readKind = DataTypeDefinition.createReader({
	[kind_u8] = function(stream)
		return stream:readString(stream:readu8())
	end,
	[kind_u16] = function(stream)
		return stream:readString(stream:readu16())
	end,
	[kind_u32] = function(stream)
		return stream:readString(stream:readu32())
	end,
})

local buffer_u8 = 4
local buffer_u16 = 5
local buffer_u32 = 6

local readBuffer = DataTypeDefinition.createReader({
	[buffer_u8] = function(stream)
		return stream:readBuffer(stream:readu8())
	end,
	[buffer_u16] = function(stream)
		return stream:readBuffer(stream:readu16())
	end,
	[buffer_u32] = function(stream)
		return stream:readBuffer(stream:readu32())
	end,
})

return DataTypeDefinition.new(userdataDefinition.typeOf, {
	read = function(stream)
		local kind = readKind(stream)
		local b = readBuffer(stream)
		return userdataDefinition:create(kind, b)
	end,
	write = function(stream, userdata)
		local userdefined = userdataDefinition:read(userdata)
		local kindLength = #userdefined.kind
		local bufferLength = buffer.len(userdefined.b)

		if kindLength <= 0xFF then
			stream:writeu8(kind_u8)
			stream:writeu8(kindLength)
		elseif kindLength <= 0xFFFF then
			stream:writeu8(kind_u16)
			stream:writeu16(kindLength)
		else
			stream:writeu8(kind_u32)
			stream:writeu32(kindLength)
		end
		stream:writeString(userdefined.kind)

		if bufferLength <= 0xFF then
			stream:writeu8(buffer_u8)
			stream:writeu8(bufferLength)
		elseif bufferLength <= 0xFFFF then
			stream:writeu8(buffer_u16)
			stream:writeu16(bufferLength)
		else
			stream:writeu8(buffer_u32)
			stream:writeu32(bufferLength)
		end
		stream:writeBuffer(userdefined.b, 0, bufferLength)
	end,
})
