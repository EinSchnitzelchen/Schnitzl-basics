Citizen.CreateThread(function()
	while ESX == nil do
	  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	  Citizen.Wait(0)
	end
end)

--Commands

--OOC Command
if Config.OOCcommand then
    RegisterNetEvent('OOC')
    AddEventHandler('OOC', function(player, closestPlayer, argString)
        TriggerClientEvent(Config.NotifyPrefix, player, "#00c4ff", "OOC - " .. GetPlayerName(player) .. "", argString)
        TriggerClientEvent(Config.NotifyPrefix, closestPlayer, "#00c4ff", "OOC - " .. GetPlayerName(player) .. "", argString)
        if (Config.NotifyPrefix == "esx:showNotification") then
            TriggerClientEvent("esx:showNotification", player, "OOC - " .. GetPlayerName(player) .. "", argString)
            TriggerClientEvent("esx:showNotification", closestPlayer, "OOC - " .. GetPlayerName(player) .. "", argString)
        end
    end, false)
end

--ID Command
if (Config.Idcommand ~= false) then
    RegisterCommand("id", function(source, args)
        if (Config.Idcommand == "notification") then
            TriggerClientEvent(Config.NotifyPrefix, source, "#00c4ff", "SERVER", "Your ID: " .. source) --This line may not work in every script, just contact me if you need help ^^
        end
        if (Config.Idcommand == "notification") and (Config.NotifyPrefix == "esx:showNotification") then --if ESX default Notify Prefix is set
            TriggerClientEvent("esx:showNotification", source, "Your ID: " .. source)
        end
        if (Config.Idcommand == "chat") then
            TriggerClientEvent('chatMessage', source, "[" .. "ID" .. "]", {0, 0, 255}, '^7 Your Server ID is: ^4 ' .. source)
        end
    end, false)
end