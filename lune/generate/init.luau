local fs = require("@lune/fs")
local process = require("@lune/process")
local run = require("@utils/run")

local commandName = process.args[1]
local writePath = process.args[2]

local result
pcall(function()
	run("rojo", { "build", "test.project.json", "--output", "test-place.rbxl" })
	result = run(
		"run-in-roblox",
		{ "--place", "test-place.rbxl", "--script", `lune/generate/{commandName}.luau` },
		{ stdio = "default" }
	)
end)

fs.writeFile(writePath, result)
