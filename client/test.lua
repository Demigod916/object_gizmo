local model = `prop_mp_cone_02`
RegisterCommand('testGizmo', function()
    local offset = GetEntityCoords(cache.ped) + GetEntityForwardVector(cache.ped) * 3
    lib.requestModel(model)
    local obj = CreateObject(model, offset.x, offset.y, offset.z, false, false, false)
    local data = exports.object_gizmo:useGizmo(obj)

    lib.print.info(data)
end)
