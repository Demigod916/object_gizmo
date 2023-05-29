local usingGizmo = false

local function toggleNuiFrame(bool)
    usingGizmo = bool
    SetNuiFocus(bool, bool)
end

function useGizmo(handle)

    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = handle,
            position = GetEntityCoords(handle),
            rotation = GetEntityRotation(handle)
        }
    })

    toggleNuiFrame(true)

    lib.showTextUI(
        ('Current Mode: %s  \n'):format("translate") ..
        '[W]    - Translate Mode  \n' ..
        '[R]    - Rotate Mode  \n' ..
        '[LALT] - Place On Ground  \n' ..
        '[Esc]  - Done Editing  \n'
    )

    while usingGizmo do

        SendNUIMessage({
            action = 'setCameraPosition',
            data = {
                position = GetFinalRenderedCamCoord(),
                rotation = GetFinalRenderedCamRot()
            }
        })
        Wait(0)
    end

    lib.hideTextUI()

    return {
        handle = handle,
        position = GetEntityCoords(handle),
        rotation = GetEntityRotation(handle)
    }
end

RegisterNUICallback('moveEntity', function(data, cb)
    local entity = data.handle
    local position = data.position
    local rotation = data.rotation

    SetEntityCoords(entity, position.x, position.y, position.z)
    SetEntityRotation(entity, rotation.x, rotation.y, rotation.z)
    cb('ok')
end)

RegisterNUICallback('placeOnGround', function(data, cb)
    PlaceObjectOnGroundProperly(data.handle)
    cb('ok')
end)

RegisterNUICallback('finishEdit', function(data, cb)
    toggleNuiFrame(false)
    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = nil,
        }
    })
    cb('ok')
end)

RegisterNUICallback('swapMode', function(data, cb)
    lib.showTextUI(
        ('Current Mode: %s  \n'):format(data.mode) ..
        '[W]    - Translate Mode  \n' ..
        '[R]    - Rotate Mode  \n' ..
        '[LALT] - Place On Ground  \n' ..
        '[Esc]  - Done Editing  \n'
    )
    cb('ok')
end)


exports("useGizmo", useGizmo)
