ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_automech:pay')
AddEventHandler('esx_automech:pay', function()
    xPlayer = ESX.GetPlayerFromId(source)

    if Config.removeMoney then
        xPlayer.removeAccountMoney('bank', Config.removeAmmount)
    else
        return
    end
end)

local LSCConnected       	   = 0

function CountLSC()

	local xPlayers = ESX.GetPlayers()

	LSCConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'mechanic' then
			LSCConnected = LSCConnected + 1
		end
	end

	SetTimeout(Config.LSCrefreshtime, CountLSC)

end

CountLSC()

RegisterServerEvent('esx_automech:get') 
AddEventHandler('esx_automech:get', function()
	local counted = {}

	counted['mechanic'] = LSCConnected

	TriggerClientEvent('esx_automech:set', source, counted)
end)