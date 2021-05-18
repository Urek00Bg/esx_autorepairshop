Config = {}

Config.Locale = 'pl'

Config.Zones = {

	LSCM = {

		Blip = {
				Sprite  = 402,
				Display = 4,
				Scale   = 0.7,
				Colour  = 29
			},

			MechInteract = {
				vector3(1139.15, -778.52, 57.18),
				vector3(1143.6, -778.52, 57.18),
				vector3(-210.97, -1323.55, 30.89),
				vector3(-336.53, -136.13, 39.01),
				vector3(-1154.76, -2006.3, 13.18),
			},

	}

}

Config.useMythic = true -- this thing here makes script use mythic_notify. If you want pNotify then leave it on true and just turn on usepNotify
Config.usepNotify = false -- this thing here makes script use pNotify. If you want pNotify then leave it on true and turn on useMythic. Else leave this on false.

Config.ActiveLSC = true -- If you have it one true then script will block script if there are enough mechanics in service
Config.LSCinService = 1 -- Number of mechanics that are needed for script to not work
Config.LSCrefreshtime = 3000 -- This is time it refreshes active LSCM in service

Config.AddBlips = true -- If you want blips then leave it on true, else false

Config.WaitTime = 10000 -- How long you need to wait for mechanic to repair your car

Config.removeMoney = true -- if you want script to remove money then leave it on true
Config.removeAmmount = 3000 -- how much money does it take when repairing your car
