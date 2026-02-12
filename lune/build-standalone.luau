local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local run = require("@utils/run")

run("rojo", { "build", "test.project.json", "--output", "test-place.rbxl" })

local function trim(s: string)
	return s:match("^%s*(.-)%s*$")
end

local gameRoot = roblox.deserializePlace(fs.readFile("test-place.rbxl"))
local packages = assert(gameRoot:GetService("ReplicatedStorage"):FindFirstChild("Packages"))

local license = roblox.Instance.new("ModuleScript")
license.Name = "LICENSE"
license.Source = `return [[\n{trim(fs.readFile("LICENSE"))}\n]]`
license.Parent = assert(packages:FindFirstChild("Bufferize"))

local standalone = roblox.Instance.new("ModuleScript")
standalone.Name = "Bufferize"
standalone.Source = trim([[
local Bufferize = require(script.Packages.Bufferize)

export type Encoder = Bufferize.Encoder
export type BufferStream = Bufferize.BufferStream

export type Supported = Bufferize.Supported
export type Overridable = Bufferize.Overridable

return Bufferize
]])

packages.Parent = standalone

local outputPath = process.args[1]
fs.writeFile(outputPath or "standalone.rbxm", roblox.serializeModel({ standalone }))
