ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}

-- Player data initialization
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

local enough = false

-- Display text at mechanic interaction points
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		local ped = PlayerPedId()
		local playercoord = GetEntityCoords(ped)

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.MechInteract, 1 do
				if Vdist2(v.MechInteract[i], playercoord) < Config.DrawDistanceText then
					DrawText3Ds(v.MechInteract[i].x, v.MechInteract[i].y, v.MechInteract[i].z, _U('inf_text'))
				end
			end
		end
	end
end)

-- Mechanic interaction and vehicle repair
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		local ped = PlayerPedId()
		local playercoord = GetEntityCoords(ped)
		local vehicle = GetVehiclePedIsIn(ped, false)

		for k, v in pairs(Config.Zones) do
			for i = 1, #v.MechInteract, 1 do
				if Vdist2(v.MechInteract[i], playercoord) < Config.InteractDistance then
					if IsControlJustPressed(1, 46) then
						if Config.ActiveLSC then
							if enough then
								Notify(_U('enoughlsc_message'))
							else
								HandleRepairProcess(vehicle)
							end
						else
							HandleRepairProcess(vehicle)
						end
					end
				end
			end
		end
	end
end)

-- Blip creation for mechanic locations
Citizen.CreateThread(function()
	for k, v in pairs(Config.Zones) do
		for i = 1, #v.MechInteract, 1 do
			if Config.AddBlips then
				local blip = AddBlipForCoord(v.MechInteract[i])

				SetBlipSprite(blip, v.Blip.Sprite)
				SetBlipDisplay(blip, v.Blip.Display)
				SetBlipScale(blip, v.Blip.Scale)
				SetBlipColour(blip, v.Blip.Colour)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName('Mechanic')
				EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

-- Helper functions
function Notify(message)
	if Config.useMythic then
		if Config.usepNotify then
			exports.pNotify:SendNotification({text = message, type = "info", timeout = 2500})
		else
			exports.mythic_notify:DoHudText('inform', message)
		end
	end
end

function HandleRepairProcess(vehicle)
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		SetVehicleDoorsLocked(vehicle, 4)
		Notify(_U('start_message'))
		FreezeEntityPosition(vehicle, true)

		Citizen.Wait(Config.WaitTime)

		SetVehicleFixed(vehicle)
		SetVehicleDeformationFixed(vehicle)
		SetVehicleUndriveable(vehicle, false)
		SetVehicleEngineOn(vehicle, true, true)
		SetVehicleDoorsLocked(vehicle, 0)
		FreezeEntityPosition(vehicle, false)

		TriggerServerEvent('esx_automech:pay')
		Notify(_U('success_message'))
	else
		Notify(_U('nocar_message'))
	end
end

function DrawText3Ds(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local factor = #text / 460
	local px, py, pz = table.unpack(GetGameplayCamCoords())
			
	SetTextScale(Config.TextX, Config.TextY)
	SetTextFont(Config.FontType)
	SetTextProportional(1)
	SetTextColour(Config.Red, Config.Green, Config.Blue, Config.Alpha)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
	DrawRect(_x, _y + Config.RectangleX, Config.RectangleW + factor, Config.RectangleH, Config.RectRed, Config.RectGreen, Config.RectBlue, Config.RectAlpha)
end

-- Mechanic job online check
RegisterNetEvent('esx_automech:set')
AddEventHandler('esx_automech:set', function(jobs_online)
	jobs = jobs_online
	enough = jobs['mechanic'] >= Config.LSCinService
end)

-- Trigger the server to get the mechanic job count
Citizen.CreateThread(function() 
	while true do
		TriggerServerEvent('esx_automech:get')
		Wait(Config.LSCrefreshtime)
	end
end)
