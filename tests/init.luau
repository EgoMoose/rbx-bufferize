local devPackagesRoot = game.ReplicatedStorage.DevPackages
local JestGlobals = require(devPackagesRoot.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local bufferizeRoot = game.ReplicatedStorage.Packages.Bufferize
local DataTypeDefinition = require(bufferizeRoot.DataTypes.DataTypeDefinition)
local BufferStream = require(bufferizeRoot.BufferStream)

local TRUNCATED_MAX = 100

type DataTypeTest<T> = {
	values: { [number]: T, n: number },
	compare: (T, T) -> boolean,
}

local TestHelper = {}

function TestHelper.values<T>(values: { [number]: T, n: number }, callback: (T) -> ())
	if values.n == 0 then
		it("should have no tests to run.", function()
			expect(true).toEqual(true)
		end)
	end

	for i = 1, values.n do
		local value = values[i]
		local valueTypeof = typeof(value)
		local truncated = tostring(value):gsub(`^{valueTypeof}: `, "")
		if #truncated > TRUNCATED_MAX then
			truncated = truncated:sub(1, TRUNCATED_MAX) .. "... [truncated]"
		end

		describe(`{i}. {valueTypeof}: {truncated}`, function()
			callback(value)
		end)
	end
end

function TestHelper.dataType<T>(definition: DataTypeDefinition.DataTypeDefinition<T>, test: DataTypeTest<T>)
	return TestHelper.values(test.values, function(value)
		local stream = BufferStream.dynamic(buffer.create(0))

		if definition.support ~= "implemented" then
			it("should fail to encode b/c the definition is unimplemented.", function()
				local success = pcall(function()
					definition:writeStream(stream, value)
				end)
				expect(success).toEqual(false)
			end)
		else
			it("should encode to a buffer.", function()
				definition:writeStream(stream, value)
				expect(typeof(stream.buffer)).toEqual("buffer")
			end)

			it("should decode losslessly.", function()
				stream.cursor = 0
				local decodedValue = definition:readStream(stream)
				expect(test.compare(decodedValue, value)).toEqual(true)
			end)

			it("should raw encode / decode losslessly at an offset.", function()
				local b, offset = definition:writeRaw(buffer.create(0), 3, value)
				local after
				b, after = definition:writeRaw(b, offset, value)
				expect(buffer.len(b)).toEqual(after)

				local decodedValue, nextOffset = definition:readRaw(b, 3)
				expect(test.compare(decodedValue, value)).toEqual(true)
				expect(nextOffset).toEqual(offset)

				local decodedValue2, nextOffset2 = definition:readRaw(b, nextOffset)
				expect(test.compare(decodedValue2, value)).toEqual(true)
				expect(nextOffset2).toEqual(after)
			end)
		end
	end)
end

function TestHelper.SKIP_WRAP(callback: () -> ())
	return describe.skip("SKIPPED", callback)
end

return TestHelper
