---
sidebar_position: 3
---

# Deduplication

When the same value appears many times in a table — the same string, the same
`Color3`, the same `CFrame` — Bufferize will write each copy to the buffer
independently. The deduplication helpers let you collapse repeated values into
pointers to a single stored instance, which can drastically shrink the buffer.

There are two helpers, depending on how much you want to commit up front:

## Deduplicate by value

[`Bufferize.deduplicate`](../api/Bufferize#deduplicate) takes a set of *exact*
values to deduplicate and rewrites the table so that every occurrence of those
values becomes a pointer.

```lua
local sharedColor = Color3.new(1, 0, 0)
local tbl = {
    a = { tint = sharedColor },
    b = { tint = sharedColor },
    c = { tint = sharedColor },
}

local compressed = Bufferize.deduplicate({ [sharedColor] = true }, tbl)
local b = Bufferize.encode(compressed)
local restored = Bufferize.reduplicate(Bufferize.decode(b))
```

## Deduplicate by type

[`Bufferize.deduplicateTypeof`](../api/Bufferize#deduplicateTypeof) is the
"figure it out for me" option: pass a set of type names (e.g. `"string"`,
`"CFrame"`) and Bufferize will find every value of those types that appears
more than once and deduplicate them automatically.

```lua
local compressed = Bufferize.deduplicateTypeof({
    string = true,
    Color3 = true,
}, tbl)
local b = Bufferize.encode(compressed)
local restored = Bufferize.reduplicate(Bufferize.decode(b))
```

## Reduplicating

After decoding, call [`Bufferize.reduplicate`](../api/Bufferize#reduplicate) to
replace the pointers with their original values. The output is a plain table
that you can use exactly as you used the original.
