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

		for k,v in pairs(Config.Zones) do
			for i=1, #v.MechInteract, 1 do
				if Vdist2(v.MechInteract[i], playercoord) < Config.DrawDistanceText then
					DrawText3Ds(v.MechInteract[i].x, v.MechInteract[i].y, v.MechInteract[i].z, _U('inf_text'))
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		local ped = GetPlayerPed(-1)
		local playercoord = GetEntityCoords(ped)
		local vehicle = GetVehiclePedIsIn(ped, false)

		for k,v in pairs(Config.Zones) do
			for i=1, #v.MechInteract, 1 do

				if Vdist2(v.MechInteract[i], playercoord) < Config.InteractDistance then
					if IsControlJustPressed(1, 46) then
						if Config.ActiveLSC then
							if enough then
								Citizen.Wait(10)
								if Config.useMythic then
									if Config.usepNotify then
										exports.pNotify:SendNotification({text = _U('enoughlsc_message'), type = "info", timeout = 2500})
									else
										exports.mythic_notify:DoHudText('inform', _U('enoughlsc_message'))
									end
								else
									return
								end
							elseif not enough then
								if IsPedInAnyVehicle(ped, false) then
									SetVehicleDoorsLocked(vehicle, 4)

									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('start_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('start_message'))
										end
									else
										return
									end

									FreezeEntityPosition(vehicle, true)

									Citizen.Wait(Config.WaitTime)

									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)

									SetVehicleDoorsLocked(vehicle, 0)
									FreezeEntityPosition(vehicle, false)

									TriggerServerEvent('esx_automech:pay')

									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('success_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('success_message'))
										end
									else
										return
									end
								else
									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('nocar_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('nocar_message'))
										end
									else
										return
									end
								end
							end
						else
							if IsControlJustPressed(1, 46) then
								if IsPedInAnyVehicle(ped, false) then
									SetVehicleDoorsLocked(vehicle, 4)

									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('start_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('start_message'))
										end
									else
										return
									end
								
									FreezeEntityPosition(vehicle, true)

									Citizen.Wait(Config.WaitTime)

									SetVehicleFixed(vehicle)
									SetVehicleDeformationFixed(vehicle)
									SetVehicleUndriveable(vehicle, false)
									SetVehicleEngineOn(vehicle, true, true)

									SetVehicleDoorsLocked(vehicle, 0)
									FreezeEntityPosition(vehicle, false)

									TriggerServerEvent('esx_automech:pay')

									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('success_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('success_message'))
										end
									else
										return
									end
								else
									if Config.useMythic then
										if Config.usepNotify then
											exports.pNotify:SendNotification({text = _U('nocar_message'), type = "info", timeout = 2500})
										else
											exports.mythic_notify:DoHudText('inform', _U('nocar_message'))
										end
									else
										return
									end
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
			if Config.AddBlips then
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
	end
end)

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
			
	SetTextScale(Config.TextX, Config.TextY)
	SetTextFont(Config.FontType)
	SetTextProportional(1)
	SetTextColour(Config.Red, Config.Green, Config.Blue, Config.Alpha)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + Config.RectangleX, Config.RectangleW + factor, Config.RectangleH, Config.RectRed, Config.RectGreen, Config.RectBlue, Config.RectAlpha)
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
