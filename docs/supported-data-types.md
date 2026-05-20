---
sidebar_position: 6
---

# Supported Data Types

The table below lists every Roblox / Luau type that Bufferize considers, and
whether it can be encoded and overridden via [custom encoding](./custom-encoding).

| **DataType**                | **Supported** | **Overridable** |
|-----------------------------|---------------|-----------------|
| **nil**                     | ✔             | ✔               |
| **boolean**                 | ✔             | ✔               |
| **function**                | ⛔             | ⛔               |
| **number**                  | ✔             | ✔               |
| **string**                  | ✔             | ✔               |
| **buffer**                  | ✔             | ✔               |
| **table**                   | ✔             | ❌               |
| **userdata**                | ⛔             | ⛔               |
| **Axes**                    | ✔             | ✔               |
| **BrickColor**              | ✔             | ✔               |
| **CatalogSearchParams**     | ❌             | ❌               |
| **CFrame**                  | ✔             | ✔               |
| **Color3**                  | ✔             | ✔               |
| **ColorSequence**           | ✔             | ✔               |
| **ColorSequenceKeypoint**   | ✔             | ✔               |
| **Content**                 | ⛔             | ⛔               |
| **DockWidgetPluginGuiInfo** | ⛔             | ⛔               |
| **Enum**                    | ✔             | ✔               |
| **EnumItem**                | ✔             | ✔               |
| **Enums**                   | ✔             | ✔               |
| **Faces**                   | ✔             | ✔               |
| **FloatCurveKey**           | ✔             | ✔               |
| **Font**                    | ✔             | ✔               |
| **Instance**                | ❌             | ❌               |
| **NumberRange**             | ✔             | ✔               |
| **NumberSequence**          | ✔             | ✔               |
| **NumberSequenceKeypoint**  | ✔             | ✔               |
| **OverlapParams**           | ⛔             | ⛔               |
| **Path2DControlPoint**      | ✔             | ✔               |
| **PathWaypoint**            | ✔             | ✔               |
| **PhysicalProperties**      | ✔             | ✔               |
| **Random**                  | ⛔             | ⛔               |
| **Ray**                     | ✔             | ✔               |
| **RaycastParams**           | ⛔             | ⛔               |
| **RaycastResult**           | ⛔             | ⛔               |
| **RBXScriptConnection**     | ⛔             | ⛔               |
| **RBXScriptSignal**         | ⛔             | ⛔               |
| **Rect**                    | ✔             | ✔               |
| **Region3**                 | ✔             | ✔               |
| **Region3int16**            | ✔             | ✔               |
| **RotationCurveKey**        | ✔             | ✔               |
| **Secret**                  | ⛔             | ⛔               |
| **SharedTable**             | ❌             | ❌               |
| **TweenInfo**               | ✔             | ✔               |
| **UDim**                    | ✔             | ✔               |
| **UDim2**                   | ✔             | ✔               |
| **ValueCurveKey**           | ⛔             | ⛔               |
| **vector**                  | ✔             | ✔               |
| **Vector2**                 | ✔             | ✔               |
| **Vector2int16**            | ✔             | ✔               |
| **Vector3**                 | ✔             | ✔               |
| **Vector3int16**            | ✔             | ✔               |

Legend:

- ✔ — implemented and ready to use.
- ❌ — not yet implemented, but supportable in principle (PRs welcome).
- ⛔ — will never be supported (the type can't be reasonably serialized).

For `Instance` specifically, see the [Instances](./instances) page — instances
are not encoded directly, but can be serialized into a plain table that *is*
encodable.
