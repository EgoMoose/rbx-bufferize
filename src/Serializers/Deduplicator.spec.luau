local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local JestGlobals = require(game.ReplicatedStorage.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local bufferizeRoot = script.Parent.Parent
local TableHelper = require(bufferizeRoot.DataTypes.Helpers.TableHelper)
local Bufferize = require(bufferizeRoot)

local function createCyclic()
	local mail = {
		email = "john.doe@email.com",
		street = "321 Road City Country",
		unit = 123,
		q = buffer.fromstring("dkhbsbdk"),
	}

	local tbl = {
		name = "John Doe",
		age = 603,
		contact = mail,
		mail = mail,
	}

	mail.x = tbl

	return tbl
end

local function createCyclic2()
	local mail = {
		email = "john.doe@email.com",
		street = "321 Road City Country",
		unit = 123,
	}

	local tbl = {
		name = "John Doe",
		age = 603,
		contact = mail,
		mail = mail,
	}

	tbl[mail] = "Howdy"
	mail[tbl] = tbl
	mail.x = tbl

	return tbl
end

local VALUES: { { [any]: any } } = {
	{ hello = "world", goodbye = { world = "hello" } },
	{ hello = "hello", world = "goodbye" },
	{ "A", "B", "C", "D" },
	{ "A", "B", nil, "C", "D" },
	{ 8, 5, 1, 7, 4 },
	createCyclic(),
	createCyclic2(),
}

TestHelper.values(table.pack(table.unpack(VALUES)), function(value)
	local deduped
	it("should serialize", function()
		deduped = Bufferize.deduplicate({ "string" }, value)
		expect(typeof(deduped)).toEqual("table")
	end)

	local encoded
	it("should encode", function()
		encoded = Bufferize.encode(deduped)
		expect(typeof(encoded)).toEqual("buffer")
	end)

	local decoded
	it("should decode", function()
		decoded = Bufferize.decode(encoded)
		expect(typeof(decoded)).toEqual("table")
	end)

	local reduped
	it("should reduplicate", function()
		reduped = Bufferize.reduplicate(decoded)
	end)

	it("should equal", function()
		local isMatching = TableHelper.equalsDeep(value, reduped, function(a, b)
			if typeof(a) == "buffer" and typeof(b) == "buffer" then
				return buffer.tostring(a) == buffer.tostring(b)
			end
			return a == b
		end)

		expect(isMatching).toEqual(true)
	end)
end)
