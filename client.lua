if Config.HandsUp.active then
    local handsUp = false
    RegisterCommand(Config.HandsUp.commandInfo.command, function ()

        local playerPed = PlayerPedId()
        if not handsUp then
            RequestAnimDict('random@mugging3')
            while (not HasAnimDictLoaded('random@mugging3')) do
                Citizen.Wait(1)
            end
            TaskPlayAnim(playerPed, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
            RemoveAnimDict('random@mugging3')

            SetCurrentPedWeapon(playerPed, -1569615261, true) --Set Playerweapon to bare Hands
            SetEnableHandcuffs(playerPed, true) --Set Player not be able to Pull/ shoot with weapons
            handsUp = true
            
        else
            handsUp = false
            ClearPedSecondaryTask(playerPed) --Clear the Animation
            SetCurrentPedWeapon(playerPed, -1569615261, true) --Set Playerweapon to bare Hands again. Just to be sure
            SetEnableHandcuffs(playerPed, false) --Set Player again be able to Pull/ shoot with weapons
        end
    end)
    
    RegisterKeyMapping(Config.HandsUp.commandInfo.command, Config.HandsUp.commandInfo.description, 'keyboard', string.upper(Config.HandsUp.keybind))
end

if Config.PointFinger.active then
    local mp_pointing = false

    local function startPointing()
        local playePed = PlayerPedId()
        RequestAnimDict("anim@mp_point")
        while not HasAnimDictLoaded("anim@mp_point") do
            Wait(0)
        end
        SetPedCurrentWeaponVisible(playePed, 0, 1, 1, 1)
        SetPedConfigFlag(playePed, 36, 1)
        TaskMoveNetworkByName(playePed, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
        RemoveAnimDict("anim@mp_point")
    end
    
    local function stopPointing()
        local playePed = PlayerPedId()
        RequestTaskMoveNetworkStateTransition(playePed, 'Stop')
        if not IsPedInjured(playePed) then
            ClearPedSecondaryTask(playePed)
        end
        if not IsPedInAnyVehicle(playePed, 1) then
            SetPedCurrentWeaponVisible(playePed, 1, 1, 1, 1)
        end
        SetPedConfigFlag(playePed, 36, 0)
        ClearPedSecondaryTask(playePed)
    end
    
    RegisterCommand(Config.PointFinger.commandInfo.command, function()
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            if mp_pointing then
                stopPointing()
                mp_pointing = false
            else
                startPointing()
                mp_pointing = true
            end
            while mp_pointing do
                local ped = PlayerPedId()
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
                _, blocked = GetRaycastResult(ray)
                SetTaskMoveNetworkSignalFloat(ped, "Pitch", camPitch)
                SetTaskMoveNetworkSignalFloat(ped, "Heading", camHeading * -1.0 + 1.0)
                SetTaskMoveNetworkSignalBool(ped, "isBlocked", blocked)
                SetTaskMoveNetworkSignalBool(ped, "isFirstPerson", GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)
                Wait(1)
            end
        end
    end)
    
    RegisterKeyMapping(Config.PointFinger.commandInfo.command, Config.PointFinger.commandInfo.description, 'keyboard', string.upper(Config.PointFinger.keybind))
end

if Config.Crouch.active then
    local crouched = false

    RegisterCommand(Config.Crouch.commandInfo.command, function ()
        local playerPed = PlayerPedId()
        if not crouched then
            RequestAnimSet("move_ped_crouched")
            while (not HasAnimSetLoaded("move_ped_crouched")) do
                Citizen.Wait(1)
            end
            SetPedMovementClipset(playerPed, 'movd_ped_crocuhed', 0.25)
            crouched = true
        else
            ResetPedMovementClipset(playerPed, 0)
            crouched = false
        end
    end)

    RegisterKeyMapping(Config.Crouch.commandInfo.command, Config.Crouch.commandInfo.description, 'keyboard', string.upper(Config.Crouch.keybind))
end
