---
sidebar_position: 1
---

# Introduction

Bufferize is a tool that losslessly encodes and decodes Roblox data types into
[`buffer`](https://create.roblox.com/docs/reference/engine/libraries/buffer) objects.

Buffers are a compact way to represent data and are well-suited to use cases like:

- Storing data in datastores
- Sending data over the network with `RemoteEvent` / `RemoteFunction`
- Persisting structured data between sessions

## Installation

### With Wally

Add Bufferize to your [`wally.toml`](https://wally.run/package/egomoose/bufferize) dependencies:

```toml
[dependencies]
Bufferize = "egomoose/bufferize@^3.0.0"
```

Then run:

```sh
wally install
```

### From a release

Download the latest `bufferize-vX.Y.Z.rbxm` model from the
[GitHub releases page](https://github.com/EgoMoose/rbx-bufferize/releases)
and drag it into Roblox Studio.

## Quick start

```lua
local Bufferize = require(path.to.Bufferize)

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

Continue to the [`Bufferize`](./api/Bufferize) API reference for the full list of
functions, or read on for more in-depth guides.
