---
sidebar_position: 2
---

# Instances

Roblox instances are not themselves a "data type" that `Bufferize.encode` accepts,
but Bufferize ships with helpers that convert an instance tree into a plain table
which can then be encoded.

```lua
local b = Bufferize.encode(Bufferize.serializeInstance(workspace.Baseplate))
local baseplateCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
```

`serializeInstance` walks the instance and all of its descendants, collecting:

- The `ClassName` of each instance.
- Every readable / writable property that differs from the class default.
- All attributes set on the instance.
- All tags set on the instance.

`deserializeInstance` reverses the process, creating fresh instances and applying
the captured state.

## Instance references

Some properties reference other instances (for example `ObjectValue.Value` or
`Motor6D.Part0`). These references are preserved **only when the referenced
instance is part of the serialized tree**.

```lua
local objV = Instance.new("ObjectValue")
local folder = Instance.new("Folder")
folder.Parent = objV

objV.Value = folder
local b = Bufferize.encode(Bufferize.serializeInstance(objV))
local objVCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
-- valid: objVCopy.Value points at the deserialized folder

objV.Value = workspace.Terrain
local b = Bufferize.encode(Bufferize.serializeInstance(objV))
local objVCopy = Bufferize.deserializeInstance(Bufferize.decode(b))
-- not preserved: objVCopy.Value == nil (Terrain wasn't part of the tree)
```

## Permissions

Properties are only included when:

- They have both read and write permissions for the current security context.
- They are not marked as deprecated.

Properties that fail to read are skipped with a warning rather than causing the
whole serialization to fail.
