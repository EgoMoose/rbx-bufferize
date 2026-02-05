local devPackagesRoot = game.ReplicatedStorage.DevPackages
local TestHelper = require(devPackagesRoot.TestHelper)

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

local function equalsDeep(a, b)
	return TestHelper.equalsDeep(a, b, function(a, b)
		if typeof(a) == "buffer" and typeof(b) == "buffer" then
			return buffer.tostring(a) == buffer.tostring(b)
		end
		return a == b
	end)
end

TestHelper.dataType(require(script.Parent.table), {
	values = table.pack(table.unpack(VALUES)),
	compare = equalsDeep,
})
