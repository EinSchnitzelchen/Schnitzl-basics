--setting locales
local handsUp = false
local crouched = false
local mp_pointing = false
local keyPressed = false
local ragdoll = false

--setting ESX
Citizen.CreateThread(function()
	while ESX == nil do
	  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	  Citizen.Wait(0)
	end
end)

--Handsup Script
if Config.handsup then
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
        DisablePlayerFiring(ped, handsUp) --Disable Playerfiring
        SetEnableHandcuffs(ped, handsUp) --Set Player not be able to Pull/ shoot with weapon
        -- It will define the value according to your hansUp state
        if handsUp then
            TaskPlayAnim(ped, animDict, anim, 8.0, 8.0, -1, 50, 0, false, false, false)
        else
            ClearPedTasks(ped) --Clear the Animation
        end
    end, false)
end

    RegisterKeyMapping('handsup', 'Toggle HandsUp', 'keyboard', Config.Controls.HandsUP)

--Crouching script

if Config.crouch then
    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(0)

            local ped = PlayerPedId()

            if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
                DisableControlAction(0, Config.ThreadControls.Crouch.keyboard, true)

                if (not IsPauseMenuActive()) then 
                    if (IsDisabledControlJustPressed(0, Config.ThreadControls.Crouch.keyboard)) and Config.crouch then 
                        RequestAnimSet(Config.Animations.Crouch.walkSet)

                        while (not HasAnimSetLoaded(Config.Animations.Crouch.walkSet)) do 
                            Citizen.Wait(100)
                        end 

                        if (crouched == true) then 
                            ResetPedMovementClipset(ped, 0)
                            crouched = false 
                        elseif (crouched == false) then
                            SetPedMovementClipset(ped, Config.Animations.Crouch.walkSet, 0.25)
                            crouched = true 
                        end 
                    end
                end 
            end 
        end
    end)
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

if Config.pointing then
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
end
    RegisterKeyMapping('point', 'Toggles Pointing', 'keyboard', Config.Controls.Point)


--Ragdoll Script
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if  ragdoll then
            SetPedToRagdoll(PlayerPedId(),1000,1000,0,true,true,false)
        end
    end
end)

if Config.ragdolled then
    RegisterCommand('rdoll', function() --Register our ragdoll command
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            ragdoll = not ragdoll
        end
    end,false)
end

RegisterKeyMapping('rdoll', 'Ragdoll', 'keyboard', Config.Controls.Ragdoll)


--Infinite Stamina Script

if Config.InfStamina then
    local ped = PlayerId()
    Citizen.CreateThread( function()
        while true do
        Wait(10000) --setting to 10s to save some resources
        RestorePlayerStamina(ped, 1.0) --Setting Playerstamina to maximum
        end
    end)
end

--NoNpc Script

if Config.NoNpc then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            -- These natives have to be called every frame.
            for i = 1, 12 do --
                EnableDispatchService(i, false) --remove this if you want to have NPC Ambulance, Firefighters ...
            end
            SetVehicleDensityMultiplierThisFrame(1.0) --If you want just a few driving NPCs change the value (I recommend 0.5 ^^)
            SetPedDensityMultiplierThisFrame(1.0) --If you want just a few walking NPCs change the value (I recommend 0.5 ^^)
            SetRandomVehicleDensityMultiplierThisFrame(2.0) -- set random vehicles (car scenarios / cars driving off from a parking spot etc.) to 0
            SetParkedVehicleDensityMultiplierThisFrame(1.0) -- set random parked vehicles (parked car scenarios) to 0
            SetScenarioPedDensityMultiplierThisFrame(2.0, 1.0) -- set random npc/ai peds or scenario peds to 0
            SetGarbageTrucks(true) -- Stop garbage trucks from randomly spawning
            SetRandomBoats(true) -- Stop random boats from spawning in the water.
            SetCreateRandomCops(false) -- disable random cops walking/driving around.
            SetCreateRandomCopsNotOnScenarios(false) -- stop random cops (not in a scenario) from spawning.
            SetCreateRandomCopsOnScenarios(false) -- stop random cops (in a scenario) from spawning.
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
            SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
            
            local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
            ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
            RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0);
        end
    end)
end



--Commands--

--OOC command
if Config.OOCcommand then
    RegisterCommand('ooc', function(source, args)
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        local argString = table.concat(args, " ")
    
        if closestPlayer ~= -1 and closestDistance <= 15.0 then
            TriggerServerEvent('OOC', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), argString)
        else
            TriggerEvent(Config.NotifyPrefix, "#00c4ff", "OOC", "No Players Nearby")
            if (Config.NotifyPrefix == "esx:showNotification") then
                TriggerEvent("esx:showNotification", source, "OOC", "No Players Nearby")
            end
        end
    end, false) --set to true = only accessable by Admins
end