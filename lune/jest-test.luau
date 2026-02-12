local fs = require("@lune/fs")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
}

local function run(program: string, params: { string }, options: Options?)
	stdio.write(stdio.style("bold"))
	print(`> {program} {table.concat(params, " ")}`)
	stdio.write(stdio.style("reset"))

	local result = process.exec(program, params, {
		shell = true,
		stdio = "forward",
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.code ~= 0 then
		process.exit(result.code)
	end

	return result.stdout:gsub("\n$", "")
end

local function enableFFlagEnableLoadModule()
	local hadFolder = true
	local pathToStudio = roblox.studioApplicationPath():gsub("\\", "/")
	local clientSettingsFolderPath = pathToStudio .. "/../ClientSettings"
	if not fs.isDir(clientSettingsFolderPath) then
		hadFolder = false
		fs.writeDir(clientSettingsFolderPath)
	end

	local hadFile = true
	local clientAppSettingsPath = clientSettingsFolderPath .. "/ClientAppSettings.json"
	if not fs.isFile(clientAppSettingsPath) then
		hadFile = false
		fs.writeFile(clientAppSettingsPath, "{}")
	end

	local contents = fs.readFile(clientAppSettingsPath)
	local clientAppSettings = serde.decode("json", contents)
	clientAppSettings.FFlagEnableLoadModule = true
	fs.writeFile(clientAppSettingsPath, serde.encode("json", clientAppSettings, true))

	return function()
		if hadFile then
			fs.writeFile(clientAppSettingsPath, contents)
		else
			fs.removeFile(clientAppSettingsPath)
		end

		if not hadFolder then
			fs.removeDir(clientSettingsFolderPath)
		end
	end
end

local cleanup = enableFFlagEnableLoadModule()

pcall(function()
	run("rojo", { "build", "test.project.json", "--output", "test-place.rbxl" })
	run("run-in-roblox", { "--place", "test-place.rbxl", "--script", "tests/TestRunner.luau" })
end)

cleanup()
if fs.isFile("test-place.rbxl") then
	fs.removeFile("test-place.rbxl")
end
