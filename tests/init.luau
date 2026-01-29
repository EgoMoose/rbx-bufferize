local devPackagesRoot = game.ReplicatedStorage.DevPackages
local JestGlobals = require(devPackagesRoot.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local bufferizeRoot = game.ReplicatedStorage.Packages.Bufferize
local DataTypeDefinition = require(bufferizeRoot.DataTypes.DataTypeDefinition)
local BufferStream = require(bufferizeRoot.BufferStream)
local Bufferize = require(bufferizeRoot)

local TRUNCATED_MAX = 100

type DataTypeTest<T> = {
	values: { [number]: T, n: number },
	compare: (T, T) -> boolean,
}

local TestHelper = {}

function TestHelper.dataType<T>(definition: DataTypeDefinition.DataTypeDefinition<T>, test: DataTypeTest<T>)
	if test.values.n == 0 then
		it("should have no tests to run.", function()
			expect(true).toEqual(true)
		end)
	end

	for i = 1, test.values.n do
		local value = test.values[i]
		local truncated = tostring(value)
		if #truncated > TRUNCATED_MAX then
			truncated = truncated:sub(1, TRUNCATED_MAX) .. "... [truncated]"
		end

		local stream = BufferStream.new(buffer.create(0))
		describe("Value: " .. truncated, function()
			if definition.unimplemented then
				it("should fail to encode b/c the definition is unimplemented.", function()
					local success = pcall(function()
						definition:writeStream(stream, value)
					end)
					expect(success).toEqual(false)
				end)
			else
				it("should encode to a buffer.", function()
					definition:writeStream(stream, value)
					expect(typeof(stream.b)).toEqual("buffer")
				end)

				it("should decode losslessly.", function()
					stream.cursor = 0
					local decodedValue = definition:readStream(stream)
					expect(test.compare(decodedValue, value)).toEqual(true)
				end)
			end
		end)
	end
end

function TestHelper.instances(test: DataTypeTest<Instance>)
	if test.values.n == 0 then
		it("should have no tests to run.", function()
			expect(true).toEqual(true)
		end)
	end

	for i = 1, test.values.n do
		local instance = test.values[i]
		local truncated = tostring(instance)
		if #truncated > TRUNCATED_MAX then
			truncated = truncated:sub(1, TRUNCATED_MAX) .. "... [truncated]"
		end

		describe("Instance: " .. truncated, function()
			local serialized
			it("should serialize.", function()
				serialized = Bufferize.serializeInstance(instance)
				expect(typeof(serialized)).toEqual("table")
			end)

			local b
			it("should encode to a buffer.", function()
				b = Bufferize.encode(serialized)
				expect(typeof(b)).toEqual("buffer")
			end)

			local decoded
			it("should decode losslessly.", function()
				decoded = Bufferize.decode(b)
				expect(typeof(decoded)).toEqual("table")
			end)

			local deserialized
			it("should deserialize.", function()
				deserialized = Bufferize.deserializeInstance(decoded)
				expect(typeof(deserialized)).toEqual("Instance")
			end)

			it("should match the original instance.", function()
				expect(test.compare(instance, deserialized)).toEqual(true)
			end)
		end)
	end
end

function TestHelper.SKIP_WRAP(callback: () -> ())
	return describe.skip("SKIPPED", callback)
end

return TestHelper
