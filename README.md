<!-- Links -->

[bufferize/releases]: https://github.com/EgoMoose/rbx-bufferize/releases
[bufferize/wally]: https://wally.run/package/egomoose/bufferize

<!-- Badges -->

[badges/github]: https://raw.githubusercontent.com/gist/cxmeel/0dbc95191f239b631c3874f4ccf114e2/raw/github.svg
[badges/wally]: https://raw.githubusercontent.com/gist/cxmeel/0dbc95191f239b631c3874f4ccf114e2/raw/wally.svg

# rbx-bufferize

[![Get it on Github][badges/github]][bufferize/releases] [![Get it on Wally][badges/wally]][bufferize/wally]

A tool to losslessly encode / decode roblox data types to buffers.

```luau
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

local b: buffer = Bufferize.encode("Hello world!", 123, true, tbl)
print(Bufferize.decode(b)) -- "Hello world!", 123, true, tbl
```

## Instances

Since instances can be converted to roblox data types it's possible for Bufferize to encode and decode them. To help with this Bufferize contains two functions to help with this process.

```luau
local b = Bufferize.encode(Bufferize.serializeInstance(workspace.Baseplate))
local baseplateCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
```

Sometimes properties are references to other instances (i.e. `ObjectValue.Value`). In order for a reference to be maintained it must be pointing to an instance that is also in the instance tree being serialized.

```luau

local objV = Instance.new("ObjectValue")
local folder = Instance.new("Folder")
folder.Parent = objV

objV.Value = folder
local b = Bufferize.encode(Bufferize.serializeInstance(folder))
local objVCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
-- valid: objVCopy.Value == folderCopy

objV.Value = workspace.Terrain
local b = Bufferize.encode(Bufferize.serializeInstance(folder))
local objVCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
-- not valid: objVCopy.Value == nil
```

## Custom Encoding

Bufferize attempts to store all data types losslessly by default. This is helpful if precision is important for you, but depending on your project it may not be needed. In order to remain flexible in this regard Bufferize supports the ability to define custom encodings for any specific data type (except tables). 

```luau
local inHouseEncoder = Bufferize.custom()

-- CFrame override that stores rotation euler angles XYZ rounded to nearest degree
-- this is not lossless, but depending on your use case it may be good enough and it results
-- in a smaller buffer size
inHouseEncoder:override("CFrame", {
	read = function(b: buffer)
		local stream = Bufferize.stream(b)
		local x, y, z = stream:readf32(), stream:readf32(), stream:readf32()
		local rx, ry, rz = math.rad(stream:readi16()), math.rad(stream:readi16()), math.rad(stream:readi16())
		return CFrame.new(x, y, z) * CFrame.fromEulerAngles(rx, ry, rz, Enum.RotationOrder.XYZ)
	end,
	write = function(cf: CFrame)
		local stream = Bufferize.stream(buffer.create(0))
		local rx, ry, rz = cf:ToEulerAngles(Enum.RotationOrder.XYZ)
		stream:writef32(cf.X)
		stream:writef32(cf.Y)
		stream:writef32(cf.Z)
		stream:writei16(math.round(math.deg(rx)))
		stream:writei16(math.round(math.deg(ry)))
		stream:writei16(math.round(math.deg(rz)))
		return stream.b
	end,
})

local complexRotation = CFrame.new(0, 0, 0, 1, 2, 3, 4)
local lengthA = buffer.len(Bufferize.encode(complexRotation))
local lengthB = buffer.len(inHouseEncoder:encode(complexRotation))
print(lengthA > lengthB) -- true
```

## Versioning

Bufferize strictly adheres to [semantic versioning](https://semver.org/).

When a buffer is encoded the current version of bufferize is included. That way when a buffer is decoded it's possible to ensure we're not attempting to decode with an incompatible version of bufferize.

For example, say you used bufferize v1.0.0 to store data in a datastore and then v2.0.0 is released. If you tried to read the v1.0.0 data with v2.0.0 bufferize then you'd get an error.

This means in practice that when a major version of bufferize releases old data will not be compatible. When the minor or patch version changes you can decode your old data with the new version of bufferize, but you can't decode your new data with the old version.

## Supported DataTypes

| **Data Type**               | **Supported** | **Overridable** |
|-----------------------------|---------------|-----------------|
| **boolean**                 | ✔             | ✔               |
| **buffer**                  | ✔             | ✔               |
| **nil**                     | ✔             | ✔               |
| **number**                  | ✔             | ✔               |
| **string**                  | ✔             | ✔               |
| **table**                   | ✔             | ⛔              |
| **userdata**                | ⛔            | ⛔              |
| **Axes**                    | ✔             | ✔               |
| **BrickColor**              | ✔             | ✔               |
| **CatalogSearchParams**     | ✔             | ✔               |
| **CFrame**                  | ✔             | ✔               |
| **Color3**                  | ✔             | ✔               |
| **ColorSequence**           | ✔             | ✔               |
| **ColorSequenceKeypoint**   | ✔             | ✔               |
| **Content**                 | ⛔            | ⛔              |
| **DockWidgetPluginGuiInfo** | ✔             | ✔               |
| **Enum**                    | ✔             | ✔               |
| **EnumItem**                | ✔             | ✔               |
| **Enums**                   | ✔             | ✔               |
| **Faces**                   | ✔             | ✔               |
| **FloatCurveKey**           | ✔             | ✔               |
| **Font**                    | ✔             | ✔               |
| **Instance**                | ❌            | ⛔              |
| **NumberRange**             | ✔             | ✔               |
| **NumberSequence**          | ✔             | ✔               |
| **NumberSequenceKeypoint**  | ✔             | ✔               |
| **OverlapParams**           | ⛔            | ⛔              |
| **Path2DControlPoint**      | ✔             | ✔               |
| **PathWaypoint**            | ✔             | ✔               |
| **PhysicalProperties**      | ✔             | ✔               |
| **Random**                  | ⛔            | ⛔              |
| **Ray**                     | ✔             | ✔               |
| **RaycastParams**           | ⛔            | ⛔              |
| **RaycastResult**           | ⛔            | ⛔              |
| **RBXScriptConnection**     | ⛔            | ⛔              |
| **RBXScriptSignal**         | ⛔            | ⛔              |
| **Rect**                    | ✔             | ✔               |
| **Region3**                 | ✔             | ✔               |
| **Region3int16**            | ✔             | ✔               |
| **RotationCurveKey**        | ✔             | ✔               |
| **Secret**                  | ⛔            | ⛔              |
| **SharedTable**             | ❌            | ❌              |
| **TweenInfo**               | ✔             | ✔               |
| **UDim**                    | ✔             | ✔               |
| **UDim2**                   | ✔             | ✔               |
| **ValueCurveKey**           | ✔             | ✔               |
| **vector**                  | ✔             | ✔               |
| **Vector2**                 | ✔             | ✔               |
| **Vector2int16**            | ✔             | ✔               |
| **Vector3**                 | ✔             | ✔               |
| **Vector3int16**            | ✔             | ✔               |


✔ Implemented  | ❌ Unimplemented | ⛔ Never

