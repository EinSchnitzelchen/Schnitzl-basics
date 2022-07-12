--setting locales
local plyPed = GetPlayerPed(-1)



Citizen.CreateThread(function() --Setting ESX
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)


Citizen.CreateThread(function()
    local handsup = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 74) then --
            if not handsup then
                ESX.Streaming.RequestAnimDict('random@mugging3', function()
                    TaskPlayAnim(plyPed, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
                    RemoveAnimDict('random@mugging3')
                end)
                SetCurrentPedWeapon(plyPed, -1569615261, true) --Set Playerweapon to bare Hands
                SetEnableHandcuffs(plyPed, true) --Set Player not be able to Pull/ shoot with weapons
                handsup = true
                end
            else
                handsup = false
                ClearPedSecondaryTask(plyPed) --Clear the Animation
                SetCurrentPedWeapon(plyPed, -1569615261, true) --Set Playerweapon to bare Hands again. Just to be sure
                SetEnableHandcuffs(plyPed, false) --Set Player again be able to Pull/ shoot with weapons
            end
        end
    end
end)