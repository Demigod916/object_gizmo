# Object Gizmo Module - object_gizmo

This README provides instructions on how to use the `object_gizmo` module in the FiveM framework using Lua. This module exports a `useGizmo` function that enables manipulation of entity position and rotation through a NUI frame.

## Installation

1. Download the `object_gizmo` resource.
2. Extract the `object_gizmo` folder into your server's `resources` directory.
3. Add `start object_gizmo` to your server's `server.cfg` file.

After installation, you can use the `useGizmo` function in your scripts: `exports['object_gizmo']:useGizmo(handle)`

## Export

`exports("useGizmo", useGizmo)`

## Functions

### useGizmo(handle)

- `handle`: The entity to be manipulated.

This function opens a NUI frame and allows for the manipulation of the entity's position and rotation. It returns an object with the entity's handle, final position, and final rotation.

## Usage

Ensure the `object_gizmo` module script is running on your server.

The `useGizmo` function can be used in any Lua script on the server or client side as follows:

```lua
local handle = --[[@ Your target entity handle]]
local result = exports['object_gizmo']:useGizmo(handle)
```

`result` will contain the entity handle, final position, and final rotation.

## Test Command

This module includes a test command `spawnobject` that demonstrates how to use the gizmo. You can use this command in-game by typing `/spawnobject {object model name}` in the console. If no object model name is provided, `prop_bench_01a` is used by default.

The command creates an object at the player's location and then activates the gizmo for that object.

```lua
RegisterCommand('spawnobject',function(source, args, rawCommand)
    local objectName = args[1] or "prop_bench_01a"
    local playerPed = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.0, 0)

    local model = joaat(objectName)
    lib.requestModel(model, 5000)

    local object = CreateObject(model, offset.x, offset.y, offset.z, true, false, false)

    local objectPositionData = exports.object_gizmo:useGizmo(object)

    print(json.encode(objectPositionData, { indent = true }))
end)
```

## Controls

While using the gizmo, the following controls apply:
- [W]: Switch to Translate Mode
- [R]: Switch to Rotate Mode
- [LAlt]: Place on Ground
- [Esc]: Finish Editing

The current mode (Translate/Rotate) will be displayed on the screen.

## Note

The gizmo only works on entities that you have sufficient permissions to manipulate. Make sure you have the correct permissions to move or rotate the entity you are working with.
