local dataview = require 'client.dataview'

local isCursorActive = false
local gizmoEnabled = false
local currentMode = 'translate'
local isRelative = false
local currentEntity

lib.locale()

--- @author DemiAutomatic
--- @method normalize
--- @description Scales a vector to unit length.
--- @param x {number}
--- @param y {number}
--- @param z {number}
--- @returns {number, number, number}
local function normalize(x, y, z)
	local length = math.sqrt(x * x + y * y + z * z)
	if length == 0 then
		return 0, 0, 0
	end
	return x / length, y / length, z / length
end

--- @author DemiAutomatic
--- @method makeEntityMatrix
--- @description Packs an entity's transform into the 4x4 float buffer the gizmo native expects.
--- @remarks GetEntityMatrix hands back forward/right/up in an order the native does not use, so
--- right is written first and forward second. The buffer is column-major with the position last.
--- @param entity {number}
--- @returns {table}
local function makeEntityMatrix(entity)
	local f, r, u, a = GetEntityMatrix(entity)
	local view = dataview.ArrayBuffer(60)

	view:SetFloat32(0, r[1])
		:SetFloat32(4, r[2])
		:SetFloat32(8, r[3])
		:SetFloat32(12, 0)
		:SetFloat32(16, f[1])
		:SetFloat32(20, f[2])
		:SetFloat32(24, f[3])
		:SetFloat32(28, 0)
		:SetFloat32(32, u[1])
		:SetFloat32(36, u[2])
		:SetFloat32(40, u[3])
		:SetFloat32(44, 0)
		:SetFloat32(48, a[1])
		:SetFloat32(52, a[2])
		:SetFloat32(56, a[3])
		:SetFloat32(60, 1)

	return view
end

--- @author DemiAutomatic
--- @method applyEntityMatrix
--- @description Writes a matrix edited by the gizmo back onto the entity.
--- @remarks Each axis is renormalised unless scaling is enabled, otherwise dragging a rotation
--- handle would slowly stretch the entity as float error accumulates.
--- @param entity {number}
--- @param view {table}
--- @returns {nil}
local function applyEntityMatrix(entity, view)
	local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
	local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
	local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
	local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)

	if not Config.enableScale then
		x1, y1, z1 = normalize(x1, y1, z1)
		x2, y2, z2 = normalize(x2, y2, z2)
		x3, y3, z3 = normalize(x3, y3, z3)
	end

	SetEntityMatrix(entity,
		x1, y1, z1,
		x2, y2, z2,
		x3, y3, z3,
		tx, ty, tz
	)
end

--- @author DemiAutomatic
--- @method gizmoLoop
--- @description Runs the gizmo until the user closes it or the entity stops existing.
--- @remarks Blocks the calling thread for the whole edit. Peds cannot take an outline, so they
--- are made translucent instead.
--- @param entity {number}
--- @returns {nil}
local function gizmoLoop(entity)
	if not gizmoEnabled then
		return LeaveCursorMode()
	end

	EnterCursorMode()
	isCursorActive = true

	if IsEntityAPed(entity) then
		SetEntityAlpha(entity, Config.pedAlpha)
	else
		local color = Config.outlineColor
		SetEntityDrawOutlineColor(color.r, color.g, color.b, color.a)
		SetEntityDrawOutlineShader(Config.outlineShader)
		SetEntityDrawOutline(entity, true)
	end

	while gizmoEnabled and DoesEntityExist(entity) do
		Wait(0)
		if IsControlJustPressed(0, 47) then -- G
			if isCursorActive then
				LeaveCursorMode()
				isCursorActive = false
			else
				EnterCursorMode()
				isCursorActive = true
			end
		end
		DisableControlAction(0, 24, true)  -- lmb
		DisableControlAction(0, 25, true)  -- rmb
		DisableControlAction(0, 140, true) -- r
		DisablePlayerFiring(cache.playerId, true)

		local matrixBuffer = makeEntityMatrix(entity)
		local changed = Citizen.InvokeNative(0xEB2EDCA2, matrixBuffer:Buffer(), 'Editor1',
			Citizen.ReturnResultAnyway())

		if changed then
			applyEntityMatrix(entity, matrixBuffer)
		end
	end

	if isCursorActive then
		LeaveCursorMode()
	end
	isCursorActive = false

	if DoesEntityExist(entity) then
		if IsEntityAPed(entity) then SetEntityAlpha(entity, 255) end
		SetEntityDrawOutline(entity, false)
	end

	gizmoEnabled = false
	currentEntity = nil
end

--- @author PickleModifications
--- @method GetVectorText
--- @description Formats the current entity's position or rotation for the text UI.
--- @param vectorType {string}
--- @returns {string}
local function GetVectorText(vectorType)
	if not currentEntity then return 'ERR_NO_ENTITY_' .. (vectorType or "UNK") end
	local label = (vectorType == "coords" and "Position" or "Rotation")
	local vec = (vectorType == "coords" and GetEntityCoords(currentEntity) or GetEntityRotation(currentEntity))
	return ('%s: %.2f, %.2f, %.2f'):format(label, vec.x, vec.y, vec.z)
end

--- @author DemiAutomatic
--- @method textUILoop
--- @description Starts the thread that keeps the on-screen control panel updated.
--- @remarks Returns immediately, so it must be started before gizmoLoop takes over the thread.
--- @returns {nil}
local function textUILoop()
	CreateThread(function()
		while gizmoEnabled do
			Wait(100)

			local scaleText = (Config.enableScale and '[S] - ' .. locale("scale_mode") .. '  \n') or ''
			local modeLine = 'Current Mode: ' .. currentMode .. ' | ' .. (isRelative and 'Relative' or 'World') .. '  \n'

			lib.showTextUI(
				modeLine ..
				GetVectorText("coords") .. '  \n' ..
				GetVectorText("rotation") .. '  \n' ..
				'[G]     - ' .. (isCursorActive and locale("disable_cursor") or locale("enable_cursor")) .. '  \n' ..
				'[W]     - ' .. locale("translate_mode") .. '  \n' ..
				'[R]     - ' .. locale("rotate_mode") .. '  \n' ..
				scaleText ..
				'[Q]     - ' .. locale("toggle_space") .. '  \n' ..
				'[LALT]  - ' .. locale("snap_to_ground") .. '  \n' ..
				'[ENTER] - ' .. locale("done_editing") .. '  \n'
			)
		end
		lib.hideTextUI()
	end)
end

--- @author DemiAutomatic
--- @method useGizmo
--- @description Opens the gizmo on an entity and reports the transform the user settled on.
--- @remarks Yields until the user presses ENTER or the entity is destroyed.
--- @param entity {number}
--- @returns {table}
local function useGizmo(entity)
	gizmoEnabled = true
	currentEntity = entity
	textUILoop()
	gizmoLoop(entity)

	return {
		handle = entity,
		position = GetEntityCoords(entity),
		rotation = GetEntityRotation(entity)
	}
end

exports("useGizmo", useGizmo)

lib.addKeybind({
	name = '_gizmoSelect',
	description = locale("select_gizmo_description"),
	defaultMapper = 'MOUSE_BUTTON',
	defaultKey = 'MOUSE_LEFT',
	onPressed = function(self)
		if not gizmoEnabled then return end
		ExecuteCommand('+gizmoSelect')
	end,
	onReleased = function (self)
		ExecuteCommand('-gizmoSelect')
	end
})

lib.addKeybind({
	name = '_gizmoTranslation',
	description = locale("translation_mode_description"),
	defaultKey = 'W',
	onPressed = function(self)
		if not gizmoEnabled then return end
		currentMode = 'Translate'
		ExecuteCommand('+gizmoTranslation')
	end,
	onReleased = function (self)
		ExecuteCommand('-gizmoTranslation')
	end
})

lib.addKeybind({
	name = '_gizmoRotation',
	description = locale("rotation_mode_description"),
	defaultKey = 'R',
	onPressed = function(self)
		if not gizmoEnabled then return end
		currentMode = 'Rotate'
		ExecuteCommand('+gizmoRotation')
	end,
	onReleased = function (self)
		ExecuteCommand('-gizmoRotation')
	end
})

lib.addKeybind({
	name = '_gizmoLocal',
	description = locale("toggle_space_description"),
	defaultKey = 'Q',
	onPressed = function(self)
		if not gizmoEnabled then return end
		isRelative = not isRelative
		ExecuteCommand('+gizmoLocal')
	end,
	onReleased = function (self)
		ExecuteCommand('-gizmoLocal')
	end
})

lib.addKeybind({
	name = 'gizmoclose',
	description = locale("close_gizmo_description"),
	defaultKey = 'RETURN',
	onReleased = function(self)
		if not gizmoEnabled then return end
		gizmoEnabled = false
	end,
})

lib.addKeybind({
	name = 'gizmoSnapToGround',
	description = locale("snap_to_ground_description"),
	defaultKey = 'LMENU',
	onPressed = function(self)
		if not gizmoEnabled then return end
		PlaceObjectOnGroundProperly_2(currentEntity)
	end,
})

if Config.enableScale then
	lib.addKeybind({
		name = '_gizmoScale',
		description = locale("scale_mode_description"),
		defaultKey = 'S',
		onPressed = function(self)
			if not gizmoEnabled then return end
			currentMode = 'Scale'
			ExecuteCommand('+gizmoScale')
		end,
		onReleased = function (self)
			ExecuteCommand('-gizmoScale')
		end
	})
end
