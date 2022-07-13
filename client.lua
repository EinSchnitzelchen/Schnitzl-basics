
local handsUp = false
local crouched = false
local mp_pointing = false
local keyPressed = false
--Handsup Script

RegisterCommand('handsup', function()
    local ped = PlayerPedId()
    local animDict = Config.Animations.HandsUp.animDict
    local anim = Config.Animations.HandsUp.anim

	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end

    handsUp = not handsUp

    SetCurrentPedWeapon(ped, -1569615261, true) --Set Playerweapon to bare Hands
    SetEnableHandcuffs(ped, handsUp) --Set Player not be able to Pull/ shoot with weapons
    -- It will define the value according to your hansUp state
    if handsUp then
        TaskPlayAnim(ped, animDict, anim, 8.0, 8.0, -1, 50, 0, false, false, false)
    else
        ClearPedTasks(ped) --Clear the Animation
    end
end, false)


if Config.handsup then
    RegisterKeyMapping('handsup', 'Toggle HandsUp', 'keyboard', Config.Controls.HandsUP)
end

--Crouching script

RegisterCommand('crouch', function()
    local ped = PlayerPedId()
    local crouchSet = Config.Animations.Crouch.walkSet

    if DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPauseMenuActive() then
        crouched = not crouched

        RequestAnimSet(crouchSet)
        while not HasAnimSetLoaded(crouchSet) do 
            Wait(0)
        end 

        if crouched then
            SetPedMovementClipset(ped, crouchSet)
        else
            ResetPedMovementClipset(ped, 0)
        end
    end 
end)

CreateThread(function() 
    while true do
    Wait(0)
        DisableControlAction(0, Config.Controls.Crouch, true)
    end
end)


if Config.crouch then
    RegisterKeyMapping('crouch', 'Toggles Crouch', 'keyboard', Config.Controls.Crouch)
end


--Pointing Script

local function startPointing()
    local ped = PlayerPedId()
    local animDict = Config.Animations.Pointing.animDict
    local anim = Config.Animations.Pointing.anim
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    TaskMoveNetworkByName(ped, anim, 0.5, false, animDict, 24)
    RemoveAnimDict(animDict)
end


local function stopPointing()
    local ped = PlayerPedId(-1)
	RequestTaskMoveNetworkStateTransition(ped, 'Stop')
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(ped)
end

RegisterCommand('point', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end

    if not mp_pointing then
        startPointing()
        mp_pointing = not mp_pointing
    else
        stopPointing()
        mp_pointing = mp_pointing
    end

    while mp_pointing do
        local camPitch = GetGameplayCamRelativePitch()
        
        if camPitch < -70.0 then
            camPitch = -70.0
        elseif camPitch > 42.0 then
            camPitch = 42.0
        end
        camPitch = (camPitch + 70.0) / 112.0

        local camHeading = GetGameplayCamRelativeHeading()
        local cosCamHeading = Cos(camHeading)
        local sinCamHeading = Sin(camHeading)
        if camHeading < -180.0 then
            camHeading = -180.0
        elseif camHeading > 180.0 then
            camHeading = 180.0
        end
        camHeading = (camHeading + 180.0) / 360.0

        local blocked

        local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
        local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7)
        _,blocked,_,_ = GetShapeTestResult(ray)

        SetTaskMoveNetworkSignalFloat(ped, 'Pitch', camPitch)
        SetTaskMoveNetworkSignalFloat(ped, 'Heading', camHeading * -1.0 + 1.0)
        SetTaskMoveNetworkSignalBool(ped, 'isBlocked', blocked)
        SetTaskMoveNetworkSignalBool(ped, 'isFirstPerson', GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)

        Wait(1)
    end
end)

if Config.pointing then
    RegisterKeyMapping('point', 'Toggles Pointing', 'keyboard', Config.Controls.Point)
end