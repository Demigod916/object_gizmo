# Object Gizmo
This is a FiveM resource that lets you control any object using the threejs Transform Controls. This is meant mainly as a tool for developers to use to create their own systems. a furniture system for example.
created by me from just gutting logic from dolu_tool and creating an export essentially.

## Installation
- drag into your resources
- add `ensure object_gizmo` to your server.cfg

## how-to

there is an example in the test.lua file. (you will probably want to remove this file before using this in production)

exports.object_gizmo:useGizmo(object)

```lua
--example of how the gizmo could be used /spawnobject {object model name}
RegisterCommand('spawnobject',function(source, args, rawCommand) 
    local objectName = args[1] or "prop_bench_01a"
    local playerPed = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.0, 0)

    local model = joaat(objectName)
    lib.requestModel(model, 5000)

    local object = CreateObject(model, offset.x, offset.y, offset.z, true, false, false)
     --export for the gizmo. just pass an object handle to the function.
    local objectPositionData = exports.object_gizmo:useGizmo(object)
    
    print(json.encode(objectPositionData, { indent = true }))
    
    -- return value of the export
    -- {
    -- handle: objectid,
    -- position: vec3,
    -- rotation: vec3
    -- }
end)



```

## preview
https://streamable.com/bp4oqp


## Credits
The react logic for the gizmo came from dolu_tool which was worked on by all of these fine people.
- **[Dolu](https://github.com/dolutattoo)**
- **[AnthonyTCS](https://github.com/AnthonyTCS)**
- **[Tiwabs](https://github.com/Tiwabs)**
- **[Lentokone](https://github.com/Aik-10)**
- **[Luke](https://github.com/Lukewastakenn)**
