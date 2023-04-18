config = {}
config.target = false -- false use marker zones. only supports ox_target, qb-target
config.jobs = {
	['police'] = 1, -- grade
	['swat'] = 1, -- grade
}
config.expiration = 3600 -- 1 hour 3600. expiration time of each evidence
config.points = {
	[1] = {
		type = 'evidence',
		label = 'Identify Evidence',
		coord = vec3(438.52890014648,-993.43432617188,30.842195510864),
	}
}

config.evidencelocker = {
	[1] = {
		type = 'stash',
		label = 'Evidence Locker',
		coord = vec3(441.73178100586,-996.37091064453,30.722442626953),
	}
}

-- bullets = when player fire a bullet and evidence will trigger to that direction
-- magazine = when player reload the weapon, evidence is triggered
-- bloods = when player take any damage, evidence is triggered
-- vehicle bullets = when player shot a vehicle evidence is triggered ( can be search by cops )
-- vehicle fragments = when player has a vehicle collision and take the minimum vehicle damage , evidence is triggered
-- fingerprint = when players drives a vehicle , evidence is triggered
--- FingerPrintArmHide Lists of Component Drawable ID from arms

config.FingerPrintArmHide = {16,15} -- if player has this GetNumberOfPedDrawableVariations(cache.ped,3) in Arms / gloves. finger print will not trigger
config.WeaponSerialOnly = false -- if player weapon does not have serial ID. bullets evidence will not trigger

config.chances = { -- chances of evidence triggered
	['bullets'] = 50, 
	['magazine'] = 70,
	['bloods'] = 50,
	['vehiclebullets'] = 70, 
	['vehiclefragments'] = 100, 
	['fingerprint'] = 60,
}

config.cooldowns = { -- how long the player can trigger the evidence again after the last evidence
	['bullets'] = 40000, -- milliseconds
	['magazine'] = 40000, -- milliseconds
	['bloods'] = 40000, -- milliseconds
	['vehiclebullets'] = 40000, -- milliseconds
	['vehiclefragments'] = 40000, -- milliseconds
}

PlayerData,ESX,QBCORE = {},currentweapon,nil,nil,nil
cd = {
	blood = 0,
	bullets = 0,
	vehiclebullets = 0,
	vehiclefragments = 0,
	magazine = 0,
}
if GetResourceState('es_extended') == 'started' then
	ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
	QBCORE = exports['qb-core']:GetCoreObject()
end