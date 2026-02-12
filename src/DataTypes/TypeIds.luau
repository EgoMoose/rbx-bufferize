local bufferizeRoot = script.Parent.Parent
local CargoSemver = require(bufferizeRoot.Parent.CargoSemver)

local TypeIds = {}

local registeredArr = {}
local function increment(semver: string)
	local registered = {
		index = #registeredArr + 1,
		semver = semver,
	}
	table.insert(registeredArr, registered)
	return registered
end

local REGISTERED_BY_TYPEOF: { [string]: typeof(increment("")) } = {
	["nil"] = increment("2.0.0"),
	["boolean"] = increment("2.0.0"),
	["function"] = increment("2.0.0"),
	["number"] = increment("2.0.0"),
	["string"] = increment("2.0.0"),
	["buffer"] = increment("2.0.0"),
	["table"] = increment("2.0.0"),

	["userdata"] = increment("2.0.0"),
	["userdata:userdefined"] = increment("2.0.0"),
	["userdata:instance-pointer"] = increment("2.0.0"),
	["userdata:deduplication-pointer"] = increment("2.0.0"),

	["Axes"] = increment("2.0.0"),
	["BrickColor"] = increment("2.0.0"),
	["CatalogSearchParams"] = increment("2.0.0"),
	["CFrame"] = increment("2.0.0"),
	["Color3"] = increment("2.0.0"),
	["ColorSequence"] = increment("2.0.0"),
	["ColorSequenceKeypoint"] = increment("2.0.0"),
	["Content"] = increment("2.0.0"),
	["DockWidgetPluginGuiInfo"] = increment("2.0.0"),
	["Enum"] = increment("2.0.0"),
	["EnumItem"] = increment("2.0.0"),
	["Enums"] = increment("2.0.0"),
	["Faces"] = increment("2.0.0"),
	["FloatCurveKey"] = increment("2.0.0"),
	["Font"] = increment("2.0.0"),
	["Instance"] = increment("2.0.0"),
	["NumberRange"] = increment("2.0.0"),
	["NumberSequence"] = increment("2.0.0"),
	["NumberSequenceKeypoint"] = increment("2.0.0"),
	["OverlapParams"] = increment("2.0.0"),
	["Path2DControlPoint"] = increment("2.0.0"),
	["PathWaypoint"] = increment("2.0.0"),
	["PhysicalProperties"] = increment("2.0.0"),
	["Random"] = increment("2.0.0"),
	["Ray"] = increment("2.0.0"),
	["RaycastParams"] = increment("2.0.0"),
	["RaycastResult"] = increment("2.0.0"),
	["RBXScriptConnection"] = increment("2.0.0"),
	["RBXScriptSignal"] = increment("2.0.0"),
	["Rect"] = increment("2.0.0"),
	["Region3"] = increment("2.0.0"),
	["Region3int16"] = increment("2.0.0"),
	["RotationCurveKey"] = increment("2.0.0"),
	["Secret"] = increment("2.0.0"),
	["SharedTable"] = increment("2.0.0"),
	["TweenInfo"] = increment("2.0.0"),
	["UDim"] = increment("2.0.0"),
	["UDim2"] = increment("2.0.0"),
	["ValueCurveKey"] = increment("2.0.0"),
	["vector"] = increment("2.0.0"),
	["Vector2"] = increment("2.0.0"),
	["Vector2int16"] = increment("2.0.0"),
	["Vector3"] = increment("2.0.0"),
	["Vector3int16"] = increment("2.0.0"),
}

table.sort(registeredArr, function(a, b)
	local aVer = CargoSemver.Version.parse(a.semver)
	local bVer = CargoSemver.Version.parse(b.semver)

	if aVer ~= bVer then
		return aVer < bVer
	end

	return a.index < b.index
end)

for i, registered in registeredArr do
	registered.index = i
end

local typeIdMax = -1
local typeIdByTypeof = {}
for typeOf, registered in REGISTERED_BY_TYPEOF do
	local typeId = registered.index - 1
	typeIdByTypeof[typeOf] = typeId
	typeIdMax = math.max(typeIdMax, typeId)
end

function TypeIds.assert(name: string)
	return assert(typeIdByTypeof[name], `No TypeId registered for name '{name}'`)
end

assert(typeIdMax <= 255, "Registered TypeIds exceed u8 limits.")
return TypeIds
