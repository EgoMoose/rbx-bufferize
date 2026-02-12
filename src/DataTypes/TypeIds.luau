local TypeIds = {}

local typeIdCount = -1
local function increment()
	typeIdCount = typeIdCount + 1
	return typeIdCount
end

local TYPE_IDS: { [string]: number } = {
	["nil"] = increment(),
	["boolean"] = increment(),
	["function"] = increment(),
	["number"] = increment(),
	["string"] = increment(),
	["buffer"] = increment(),
	["table"] = increment(),

	["userdata"] = increment(),
	["userdata:userdefined"] = increment(),
	["userdata:pointer"] = increment(),

	["Axes"] = increment(),
	["BrickColor"] = increment(),
	["CatalogSearchParams"] = increment(),
	["CFrame"] = increment(),
	["Color3"] = increment(),
	["ColorSequence"] = increment(),
	["ColorSequenceKeypoint"] = increment(),
	["Content"] = increment(),
	["DockWidgetPluginGuiInfo"] = increment(),
	["Enum"] = increment(),
	["EnumItem"] = increment(),
	["Enums"] = increment(),
	["Faces"] = increment(),
	["FloatCurveKey"] = increment(),
	["Font"] = increment(),
	["Instance"] = increment(),
	["NumberRange"] = increment(),
	["NumberSequence"] = increment(),
	["NumberSequenceKeypoint"] = increment(),
	["OverlapParams"] = increment(),
	["Path2DControlPoint"] = increment(),
	["PathWaypoint"] = increment(),
	["PhysicalProperties"] = increment(),
	["Random"] = increment(),
	["Ray"] = increment(),
	["RaycastParams"] = increment(),
	["RaycastResult"] = increment(),
	["RBXScriptConnection"] = increment(),
	["RBXScriptSignal"] = increment(),
	["Rect"] = increment(),
	["Region3"] = increment(),
	["Region3int16"] = increment(),
	["RotationCurveKey"] = increment(),
	["Secret"] = increment(),
	["SharedTable"] = increment(),
	["TweenInfo"] = increment(),
	["UDim"] = increment(),
	["UDim2"] = increment(),
	["ValueCurveKey"] = increment(),
	["vector"] = increment(),
	["Vector2"] = increment(),
	["Vector2int16"] = increment(),
	["Vector3"] = increment(),
	["Vector3int16"] = increment(),
}

function TypeIds.assert(name: string)
	return assert(TYPE_IDS[name], `No TypeId registered for name '{name}'`)
end

assert(typeIdCount <= 255, "Registered TypeIds exceed u8 limits.")
return TypeIds
