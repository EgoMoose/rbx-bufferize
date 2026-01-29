--!strict

local BufferStreamStatic = {}

local BufferStreamClass = {}
BufferStreamClass.__index = BufferStreamClass
BufferStreamClass.ClassName = "BufferStream"

export type BufferStream = typeof(setmetatable(
	{} :: {
		b: buffer,
		cursor: number,
		length: number,
	},
	BufferStreamClass
))

function BufferStreamStatic.new(b: buffer)
	local self = setmetatable({}, BufferStreamClass) :: BufferStream

	self.b = b
	self.cursor = 0
	self.length = buffer.len(b)

	return self
end

-- Private

local function readUnsignedBytes(b: buffer, offset: number, bytes: number)
	-- selene: allow(incorrect_standard_library_use)
	return buffer.readbits(b, offset * 8, bytes * 8)
end

local function writeUnsignedBytes(b: buffer, offset: number, bytes: number, value: number)
	-- selene: allow(incorrect_standard_library_use)
	return buffer.writebits(b, offset * 8, bytes * 8, value)
end

local function cursorWrite<T...>(self: BufferStream, bytes: number, callback: (buffer, number, T...) -> (), ...: T...)
	local newCursor = self.cursor + bytes
	if newCursor > self.length then
		self:expand(newCursor - self.length)
	end
	callback(self.b, self.cursor, ...)
	self.cursor = newCursor
end

-- Methods

function BufferStreamClass.expand(self: BufferStream, bytes: number)
	self.length = self.length + bytes
	local expanded = buffer.create(self.length)
	buffer.copy(expanded, 0, self.b)
	self.b = expanded
end

function BufferStreamClass.readUnsignedBytes(self: BufferStream, bytes: number)
	local result = readUnsignedBytes(self.b, self.cursor, bytes)
	self.cursor = self.cursor + bytes
	return result
end

function BufferStreamClass.writeUnsignedBytes(self: BufferStream, bytes: number, value: number)
	cursorWrite(self, bytes, writeUnsignedBytes, bytes, value)
end

function BufferStreamClass.readu8(self: BufferStream)
	local result = buffer.readu8(self.b, self.cursor)
	self.cursor = self.cursor + 1
	return result
end

function BufferStreamClass.writeu8(self: BufferStream, u8: number)
	cursorWrite(self, 1, buffer.writeu8, u8)
end

function BufferStreamClass.readu16(self: BufferStream)
	local result = buffer.readu16(self.b, self.cursor)
	self.cursor = self.cursor + 2
	return result
end

function BufferStreamClass.writeu16(self: BufferStream, u16: number)
	cursorWrite(self, 2, buffer.writeu16, u16)
end

function BufferStreamClass.readu32(self: BufferStream)
	local result = buffer.readu32(self.b, self.cursor)
	self.cursor = self.cursor + 4
	return result
end

function BufferStreamClass.writeu32(self: BufferStream, u32: number)
	cursorWrite(self, 4, buffer.writeu32, u32)
end

function BufferStreamClass.readi8(self: BufferStream)
	local result = buffer.readi8(self.b, self.cursor)
	self.cursor = self.cursor + 1
	return result
end

function BufferStreamClass.writei8(self: BufferStream, i8: number)
	cursorWrite(self, 1, buffer.writei8, i8)
end

function BufferStreamClass.readi16(self: BufferStream)
	local result = buffer.readi16(self.b, self.cursor)
	self.cursor = self.cursor + 2
	return result
end

function BufferStreamClass.writei16(self: BufferStream, i16: number)
	cursorWrite(self, 2, buffer.writei16, i16)
end

function BufferStreamClass.readi32(self: BufferStream)
	local result = buffer.readi32(self.b, self.cursor)
	self.cursor = self.cursor + 4
	return result
end

function BufferStreamClass.writei32(self: BufferStream, i32: number)
	cursorWrite(self, 4, buffer.writei32, i32)
end

function BufferStreamClass.readf32(self: BufferStream)
	local result = buffer.readf32(self.b, self.cursor)
	self.cursor = self.cursor + 4
	return result
end

function BufferStreamClass.writef32(self: BufferStream, f32: number)
	cursorWrite(self, 4, buffer.writef32, f32)
end

function BufferStreamClass.readf64(self: BufferStream)
	local result = buffer.readf64(self.b, self.cursor)
	self.cursor = self.cursor + 8
	return result
end

function BufferStreamClass.writef64(self: BufferStream, f64: number)
	cursorWrite(self, 8, buffer.writef64, f64)
end

function BufferStreamClass.readString(self: BufferStream, bytes: number)
	local result = buffer.readstring(self.b, self.cursor, bytes)
	self.cursor = self.cursor + bytes
	return result
end

function BufferStreamClass.writeString(self: BufferStream, value: string, count: number?)
	local length = (count or #value)
	cursorWrite(self, length, buffer.writestring, value, length)
end

function BufferStreamClass.readBuffer(self: BufferStream, bytes: number)
	local b = buffer.create(bytes)
	buffer.copy(b, 0, self.b, self.cursor, bytes)
	self.cursor = self.cursor + bytes
	return b
end

function BufferStreamClass.writeBuffer(self: BufferStream, b: buffer, offset: number?, count: number?)
	local length = count or buffer.len(b)
	cursorWrite(self, length, buffer.copy, b, offset or 0, length)
end

function BufferStreamClass.readTypeId(self: BufferStream)
	return self:readu8()
end

function BufferStreamClass.writeTypeId(self: BufferStream, typeId: number)
	self:writeu8(typeId)
end

--

return BufferStreamStatic
