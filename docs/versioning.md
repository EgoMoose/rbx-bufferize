---
sidebar_position: 4
---

# Versioning

Bufferize strictly adheres to [semantic versioning](https://semver.org/).

When a buffer is encoded the current version of Bufferize is written into its
header. When a buffer is decoded that version is checked against the running
version to ensure they are compatible.

For example, say you encoded data with Bufferize `v1.0.0` and stored it in a
datastore. Some time later you upgrade to `v2.0.0`:

- Reading the `v1.0.0` data with `v2.0.0` Bufferize will **error**.
- Reading `v2.0.0` data with a stale `v1.0.0` client will also **error**.

In practice:

- A **major** version bump breaks compatibility with all previously encoded data.
- A **minor** or **patch** bump is forward-compatible: old data can be decoded
  by the newer Bufferize, but newly-encoded data can't be decoded by an older one.

You can inspect the version stored in a buffer without decoding the body via
[`Bufferize.readVersion`](./api/Bufferize#readVersion), and the version of the
running module is available as [`Bufferize.VERSION`](./api/Bufferize#VERSION).
