ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

local enough = false

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		local ped = GetPlayerPed(-1)
		local playercoord = GetEntityCoords(ped)
		local vehicle = GetVehiclePedIsIn(ped, false)

		for k,v in pairs(Config.Zones) do
			for i=1, #v.MechInteract, 1 do

				if Vdist2(v.MechInteract[i], playercoord) < 3 then
					DrawText3Ds(v.MechInteract[i].x, v.MechInteract[i].y, v.MechInteract[i].z, 'Press [E] to get mechanic attention')
					if IsControlJustPressed(1, 46) then
						if Config.ActiveLSC then
							if enough then
								Citizen.Wait(10)
								exports.mythic_notify:DoHudText('inform', 'Our mechanic is busy. Go to main mechanic!')
							elseif not enough then
								if IsPedInAnyVehicle(ped, false) then
									SetVehicleDoorsLocked(vehicle, 4)
									exports.mythic_notify:DoHudText('inform', 'Your car is being taken care of')

									FreezeEntityPosition(vehicle, true)

									Citizen.Wait(Config.WaitTime)

									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)

									SetVehicleDoorsLocked(vehicle, 0)
									FreezeEntityPosition(vehicle, false)

									TriggerServerEvent('esx_automech:pay')

									exports.mythic_notify:DoHudText('inform', 'Isnt this car beatifull now?')
								else
									exports.mythic_notify:DoHudText('inform', 'You want me to repair your brain?')
								end
							end
						else
							if IsControlJustPressed(1, 46) then
								if IsPedInAnyVehicle(ped, false) then
									SetVehicleDoorsLocked(vehicle, 4)
									exports.mythic_notify:DoHudText('inform', 'Your car is being taken care of')
								
									FreezeEntityPosition(vehicle, true)

									Citizen.Wait(Config.WaitTime)

									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)

									SetVehicleDoorsLocked(vehicle, 0)
									FreezeEntityPosition(vehicle, false)

									TriggerServerEvent('esx_automech:pay')

									exports.mythic_notify:DoHudText('inform', 'Isnt this car beatifull now?')
								else
									exports.mythic_notify:DoHudText('inform', 'You want me to repair your brain?')
								end
							end
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.Zones) do
		for i = 1, #v.MechInteract, 1 do
			local blip = AddBlipForCoord(v.MechInteract[i])

			SetBlipSprite (blip, v.Blip.Sprite)
			SetBlipDisplay(blip, v.Blip.Display)
			SetBlipScale  (blip, v.Blip.Scale)
			SetBlipColour (blip, v.Blip.Colour)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName('Mechanik')
			EndTextCommandSetBlipName(blip)
		end
	end
end)

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end

RegisterNetEvent('esx_automech:set')
AddEventHandler('esx_automech:set', function(jobs_online)
	jobs = jobs_online

    if jobs['mechanic'] < Config.LSCinService then
        enough = false
    elseif jobs['mechanic'] >= Config.LSCinService then
        enough = true
    end
end)

Citizen.CreateThread(function() 
	while true do
		TriggerServerEvent('esx_automech:get')

		Wait(Config.LSCrefreshtime)
	end
end)