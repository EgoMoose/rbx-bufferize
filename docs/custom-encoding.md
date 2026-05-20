---
sidebar_position: 3
---

# Custom Encoding

Bufferize encodes data losslessly by default. That's the safe option, but it's
not always what you want — sometimes a smaller buffer is more valuable than
sub-pixel precision.

`Bufferize.custom()` returns an [`Encoder`](./api/Encoder) you can configure with
custom read/write functions for any overridable type.

```lua
local inHouseEncoder = Bufferize.custom()

-- CFrame override that stores rotation euler angles XYZ rounded to nearest degree.
-- This is not lossless, but depending on your use case it may be good enough,
-- and it results in a smaller buffer.
inHouseEncoder:override("CFrame", {
    read = function(b: buffer)
        local x = buffer.readf32(b, 0)
        local y = buffer.readf32(b, 4)
        local z = buffer.readf32(b, 8)
        local rx = math.rad(buffer.readi16(b, 12))
        local ry = math.rad(buffer.readi16(b, 14))
        local rz = math.rad(buffer.readi16(b, 16))
        return CFrame.new(x, y, z) * CFrame.fromEulerAngles(rx, ry, rz, Enum.RotationOrder.XYZ)
    end,
    write = function(cf: CFrame)
        local b = buffer.create(18)
        local rx, ry, rz = cf:ToEulerAngles(Enum.RotationOrder.XYZ)
        buffer.writef32(b, 0, cf.X)
        buffer.writef32(b, 4, cf.Y)
        buffer.writef32(b, 8, cf.Z)
        buffer.writei16(b, 12, math.round(math.deg(rx)))
        buffer.writei16(b, 14, math.round(math.deg(ry)))
        buffer.writei16(b, 16, math.round(math.deg(rz)))
        return b
    end,
})

local complexRotation = CFrame.new(0, 0, 0, 1, 2, 3, 4)
local lengthA = buffer.len(Bufferize.encode(complexRotation))
local lengthB = buffer.len(inHouseEncoder:encode(complexRotation))
print(lengthA > lengthB) -- true
```

The same encoder must be used to both `encode` and `decode` a buffer — there's
no way to recover the override information from the buffer itself.

## What can be overridden?

Almost every supported data type can be overridden. Tables cannot, because
Bufferize relies on its own table walker to preserve shared references and
shape. See the [supported data types](./supported-data-types) page for the full
matrix.

Calling `override` for a type that isn't overridable will raise an error.
