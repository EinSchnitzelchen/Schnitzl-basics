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
    
    RegisterKeyMapping(Config.HandsUp.commandInfo.command, Config.HandsUp.commandInfo.description, string.upper(Config.HandsUp.keybind), 'KEYBOARD')
end

if Config.PointFinger.active then
    local pointing = false

    local function startPointing()
        pointing = true
        local playerPed = PlayerPedId()
        RequestAnimDict("anim@mp_point")
        while not HasAnimDictLoaded("anim@mp_point") do
            Wait(0)
        end
        SetPedCurrentWeaponVisible(playerPed, 0, 1, 1, 1)
        SetPedConfigFlag(playerPed, 36, 1)
        TaskMoveNetworkAdvancedByName(playerPed, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
        RemoveAnimDict("anim@mp_point")
    end
    
    local function stopPointing()
        pointing = false
        local playerPed = PlayerPedId()

        RequestTaskMoveNetworkStateTransition(playerPed, "Stop")
        if not IsPedInjured(playerPed) then
            ClearPedSecondaryTask(playerPed)
        end
        if not IsPedInAnyVehicle(playerPed, 1) then
            SetPedCurrentWeaponVisible(playerPed, 1, 1, 1, 1)
        end
        SetPedConfigFlag(playerPed, 36, 0)
        ClearPedSecondaryTask(playerPed)
    end

    RegisterCommand(Config.PointFinger.commandInfo.command, function ()
        if not pointing then
            startPointing()
        else
            stopPointing()
        end
    end)

    RegisterKeyMapping(Config.PointFinger.commandInfo.command, Config.PointFinger.commandInfo.description, string.upper(Config.PointFinger.keybind), 'KEYBOARD')
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

    RegisterKeyMapping(Config.Crouch.commandInfo.command, Config.Crouch.commandInfo.description, Config.Crouch.keybind, 'KEYBOARD')
end
