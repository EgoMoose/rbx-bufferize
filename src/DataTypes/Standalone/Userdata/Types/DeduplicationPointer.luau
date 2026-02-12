local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local userdataRoot = script:FindFirstAncestor("Userdata")
local UserdataDefinitions = require(userdataRoot.Definitions)
local userdataDefinition = UserdataDefinitions.DeduplicationPointer

local pointer_u8 = 1
local pointer_u16 = 2
local pointer_u32 = 3
local pointer_f64 = 4

return DataTypeDefinition.new(userdataDefinition.typeOf, {
	read = DataTypeDefinition.createReader({
		[pointer_u8] = function(stream)
			return userdataDefinition:create(stream:readu8())
		end,
		[pointer_u16] = function(stream)
			return userdataDefinition:create(stream:readu16())
		end,
		[pointer_u32] = function(stream)
			return userdataDefinition:create(stream:readu32())
		end,
		[pointer_f64] = function(stream)
			return userdataDefinition:create(stream:readf64())
		end,
	}),
	write = function(stream, userdata)
		local pointer = userdataDefinition:read(userdata)
		local pointerIndex = pointer.index

		if pointerIndex <= 0xFF then
			stream:writeu8(pointer_u8)
			stream:writeu8(pointerIndex)
		elseif pointerIndex <= 0xFFFF then
			stream:writeu8(pointer_u16)
			stream:writeu16(pointerIndex)
		elseif pointerIndex <= 0xFFFFFFFF then
			stream:writeu8(pointer_u32)
			stream:writeu32(pointerIndex)
		else
			stream:writeu8(pointer_f64)
			stream:writef64(pointerIndex)
		end
	end,
})
