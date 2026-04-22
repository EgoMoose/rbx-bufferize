local BufferStreamPkg = require(script.Parent.Parent.BufferStream)

local BufferStream = {}

export type BufferStream = BufferStreamPkg.BufferStream

BufferStream.static = BufferStreamPkg.static
BufferStream.dynamic = BufferStreamPkg.dynamic

function BufferStream.readTypeId(stream: BufferStream)
	return stream:readu8()
end

function BufferStream.writeTypeId(stream: BufferStream, typeId: number)
	stream:writeu8(typeId)
end

return BufferStream
