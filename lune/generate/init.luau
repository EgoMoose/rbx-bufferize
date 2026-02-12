local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

type Options = {
	stdio: string?,
	cwd: string?,
	env: { [string]: string }?,
}

local function run(program: string, params: { string }, options: Options?)
	stdio.write(stdio.style("bold"))
	print(`> {program} {table.concat(params, " ")}`)
	stdio.write(stdio.style("reset"))

	local result = process.exec(program, params, {
		shell = true,
		stdio = options and (options.stdio :: any) or "forward",
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.code ~= 0 then
		process.exit(result.code)
	end

	return result.stdout:gsub("\n$", "")
end

local arg1 = process.args[1]
local arg2 = process.args[2]

local result
pcall(function()
	run("rojo", { "build", "test.project.json", "--output", "test-place.rbxl" })
	result = run(
		"run-in-roblox",
		{ "--place", "test-place.rbxl", "--script", `lune/generate/{arg1}.luau` },
		{ stdio = "default" }
	)
end)

fs.writeFile(arg2, result)
