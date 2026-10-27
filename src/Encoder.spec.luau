local JestGlobals = require(game.ReplicatedStorage.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local bufferizeRoot = script.Parent
local Bufferize = require(bufferizeRoot)

local function headerOnly(version: string)
	local b = buffer.create(1 + #version)
	buffer.writeu8(b, 0, #version)
	buffer.writestring(b, 1, version)
	return b
end

local majorStr, minorStr, patchStr = string.match(Bufferize.VERSION, "^(%d+)%.(%d+)%.(%d+)")
local MAJOR = assert(tonumber(majorStr), "Failed to read the running major version.")
local MINOR = assert(tonumber(minorStr), "Failed to read the running minor version.")
local PATCH = assert(tonumber(patchStr), "Failed to read the running patch version.")

describe("isCompatible", function()
	it("should accept a buffer encoded by the running version.", function()
		local b = Bufferize.encode("Hello world!", 123, true, { foo = "bar" })
		expect(Bufferize.isCompatible(b)).toEqual(true)
	end)

	it("should accept an older version within the same major version.", function()
		expect(Bufferize.isCompatible(headerOnly(`{MAJOR}.0.0`))).toEqual(true)
	end)

	it("should reject a newer version within the same major version.", function()
		expect(Bufferize.isCompatible(headerOnly(`{MAJOR}.{MINOR}.{PATCH + 1}`))).toEqual(false)
	end)

	it("should reject a newer major version.", function()
		expect(Bufferize.isCompatible(headerOnly(`{MAJOR + 1}.0.0`))).toEqual(false)
	end)

	if MAJOR > 0 then
		it("should reject an older major version.", function()
			expect(Bufferize.isCompatible(headerOnly(`{MAJOR - 1}.0.0`))).toEqual(false)
		end)
	end

	it("should reject a malformed version header.", function()
		expect(Bufferize.isCompatible(headerOnly("not.a.version"))).toEqual(false)
	end)

	it("should reject an empty buffer.", function()
		expect(Bufferize.isCompatible(buffer.create(0))).toEqual(false)
	end)

	it("should reject a buffer that was not produced by encode.", function()
		expect(Bufferize.isCompatible(buffer.fromstring("this was never a bufferize buffer"))).toEqual(false)
	end)

	it("should agree with decode.", function()
		local b = Bufferize.encode("Hello world!")
		expect(Bufferize.isCompatible(b)).toEqual(pcall(Bufferize.decode, b))

		local incompatible = headerOnly(`{MAJOR + 1}.0.0`)
		expect(Bufferize.isCompatible(incompatible)).toEqual(pcall(Bufferize.decode, incompatible))
	end)
end)

describe("readVersion", function()
	it("should read back the running version.", function()
		expect(Bufferize.readVersion(Bufferize.encode("Hello world!"))).toEqual(Bufferize.VERSION)
	end)

	it("should return nil for a buffer that was not produced by encode.", function()
		expect(Bufferize.readVersion(buffer.create(0))).toEqual(nil)
		expect(Bufferize.readVersion(headerOnly("not.a.version"))).toEqual(nil)
	end)
end)

describe("read / write", function()
	it("should round trip multiple values packed into one buffer.", function()
		local cf = CFrame.new(1, 2, 3) * CFrame.Angles(0.1, 0.2, 0.3)
		local v = Vector3.new(4, 5, 6)

		local b, offset = Bufferize.write.CFrame(buffer.create(0), 0, cf)
		b, offset = Bufferize.write.Vector3(b, offset, v)
		b, offset = Bufferize.write.string(b, offset, "Hello world!")
		expect(buffer.len(b)).toEqual(offset)

		local readCF, readOffset = Bufferize.read.CFrame(b, 0)
		local readV, readStr
		readV, readOffset = Bufferize.read.Vector3(b, readOffset)
		readStr, readOffset = Bufferize.read.string(b, readOffset)

		expect(readCF).toEqual(cf)
		expect(readV).toEqual(v)
		expect(readStr).toEqual("Hello world!")
		expect(readOffset).toEqual(offset)
	end)

	it("should write in place when the buffer is large enough.", function()
		local b = buffer.create(64)
		local written, offset = Bufferize.write.Vector3(b, 8, Vector3.new(1, 2, 3))
		expect(written).toBe(b)
		expect((Bufferize.read.Vector3(b, 8))).toEqual(Vector3.new(1, 2, 3))
		expect(offset > 8).toEqual(true)
	end)

	it("should not include a type id.", function()
		local b = Bufferize.write.Vector3(buffer.create(0), 0, Vector3.new(1, 2, 3))
		local encoded = Bufferize.encode(Vector3.new(1, 2, 3))
		expect(buffer.len(b) < buffer.len(encoded)).toEqual(true)
	end)

	it("should not expose unsupported types.", function()
		local readers = Bufferize.read :: any
		local writers = Bufferize.write :: any
		expect(readers.Instance).toBeNil()
		expect(writers.Instance).toBeNil()
		expect(readers["userdata:Userdefined"]).toBeNil()
	end)
end)
