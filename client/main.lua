
function GetStreetNames(player)
	local pos = GetEntityCoords(player)
	local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
    return GetStreetNameFromHashKey(street1)..', '..GetStreetNameFromHashKey(street2)
end

local lastvehiclehealth = 1000.0
local currentvehicle = nil
AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkEntityDamage' then
		local victim = args[1]
		local attacker = args[2]
		local weaponHash = args[7]
		local isMelee = args[12]
		local isVehicleCollision = weaponHash == 133987706
		local ismyvehicle = currentvehicle == victim
		local isjob = config.jobs[PlayerData?.job?.name]
		if not isjob and victim == cache.ped and cd['blood'] < GetGameTimer() and math.random(1,100) <= config.chances['bloods'] then
			local targetedCoord = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, -1.0)
			local _, z = GetGroundZFor_3dCoord(targetedCoord.x,targetedCoord.y,targetedCoord.z+3.0,false)
			cd['blood'] = GetGameTimer() + config.cooldowns['bloods']
			LocalPlayer.state:set('bloods', {coord = vec3(targetedCoord.x,targetedCoord.y,z), location = GetStreetNames(cache.ped)}, true)
		elseif not isjob and IsEntityAVehicle(victim) and not isVehicleCollision and isMelee == 0 and attacker == cache.ped and cd['vehiclebullets'] < GetGameTimer() and math.random(1,100) <= config.chances['vehiclebullets'] then
			cd['vehiclebullets'] = GetGameTimer() + config.cooldowns['vehiclebullets']
			if config.WeaponSerialOnly and not currentweapon?.metadata?.serial then return end
			Entity(victim).state:set("vehiclebullets", {serial = currentweapon?.metadata?.serial, coord = GetEntityCoords(cache.ped), info = {identifier = PlayerData.identifier, location = GetStreetNames(cache.ped), weapon = currentweapon.label}},true)
		elseif isVehicleCollision and ismyvehicle then
			if (lastvehiclehealth - GetVehicleBodyHealth(victim)) > 20 and cd['vehiclefragments'] < GetGameTimer() and math.random(1,100) <= config.chances['vehiclefragments'] then	
				cd['vehiclefragments'] = GetGameTimer() + config.cooldowns['vehiclefragments']
				local targetedCoord = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, -1.0)
				local _, z = GetGroundZFor_3dCoord(targetedCoord.x,targetedCoord.y,targetedCoord.z+3.0,false)
				LocalPlayer.state:set('vehiclefragments', {coord = vec3(targetedCoord.x,targetedCoord.y,z), location = GetStreetNames(cache.ped), plate = GetVehicleNumberPlateText(currentvehicle)}, true)
				lastvehiclehealth = GetVehicleBodyHealth(victim)
			end
			lastvehiclehealth = GetVehicleBodyHealth(victim)
		end
	end
end)


function func_522(x, y, z)
    local fVar1;
    local fVar0 = math.sqrt(x * x + y * y + z * z)
    local vParam0

    if (fVar0 ~= 0.0) then
        fVar1 = (1.0 / fVar0);
        vParam0 = vector3(x, y, z) * vector3(fVar1, fVar1, fVar1)
    end

    return vParam0 or vector3(0.0, 0.0, 0.0);
end

CreateBloodFx = function(targetedCoord)
	SetParticleFxBulletImpactScale(2.0)
	N_0x5f6df3d92271e8a1(true)
	--lib.requestNamedPtfxAsset('core') -- blood_stab
	decal = AddDecal(
        1010,
        targetedCoord.x, targetedCoord.y, targetedCoord.z+0.1, -- pos
        func_522(0.0, 1.0, 0.0), -- unk
        func_522(0.0, 1.0, 0.0), --unk
        2.0, 2.0, --width, height
        1.255, 0.0, 0.0,    -- rgb
        1.0, 87878.0,    -- opacity,timeout
        0, 0, 0 -- unk
    )
	--SetPtfxAssetNextCall('core')
	--blood =  StartNetworkedParticleFxNonLoopedOnPedBone('blood_stab', cache.ped, 0.05, -0.0000, 0.0000, 0.0, 180.0, 0.0, 57005, 0.8, false, false, false)
end

TakeEvidence = function(data)
	local dict = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@'
	lib.RequestAnimDict(dict)
	TaskPlayAnim(cache.ped, dict, 'plant_floor', 8.0, 1.0, 1000, 16, 0.0, false, false, false)
	lib.hideTextUI()
	return lib.callback.await('renzu_evidence:removeevidence',false,data)
end

function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(weapon,distance,flag)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance, 
		cameraCoord.y + direction.y * distance, 
		cameraCoord.z + direction.z * distance 
    )
    if not flag then
        flag = 1
    end

	local a, b, c, d, e = GetShapeTestResultIncludingMaterial(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

local bloodcaches = {}
AddStateBagChangeHandler("Evidence", "global", function(bagName, key, value)
	Wait(11)
	for k,v in pairs(value?.bloods or {}) do
		if not bloodcaches[k] then
			bloodcaches[k] = true
			CreateBloodFx(v.coord)
		end
	end
end)

isPlayerHaveGloves = function(arm)
	for k,v in pairs(config.FingerPrintArmHide) do
		if v == arm then return true end
	end
	return false
end

lib.onCache('vehicle', function(value)
    if value then
		currentvehicle = value
		lastvehiclehealth = GetVehicleBodyHealth(value)
		local job = PlayerData?.job?.name
        local ent = Entity(value).state
		local arm = GetNumberOfPedDrawableVariations(cache.ped,3)
		if job and not isPlayerHaveGloves(arm) and math.random(1,100) <= config.chances['fingerprint'] and GetPedInVehicleSeat(value,-1) == cache.ped and not config.jobs[job] then
			ent:set('fingerprint', {coord = coord, plate = GetVehicleNumberPlateText(value), info = {identifier = PlayerData.identifier, location = GetStreetNames(cache.ped)}}, true)
		elseif job and ent.vehiclebullets and config.jobs[job] then
			lib.showTextUI('[E] - Search Vehicle', {
				position = "top-right",
				icon = 'exclamation',
				style = {
					borderRadius = 0,
					backgroundColor = 'red',
					color = 'white'
				}
			})
			while IsPedInAnyVehicle(cache.ped) do
				Wait(1)
				if IsControlJustReleased(0,38) then
					lib.progressBar({
						duration = 5000,
						label = 'Searching Vehicle',
						useWhileDead = false,
						canCancel = false,
					})
					local ent = Entity(value).state
					local net = NetworkGetNetworkIdFromEntity(value)
					if ent.vehiclebullets then
						TakeEvidence({info = ent.vehiclebullets.info, plate = ent.vehiclebullets.plate, entity = net, type = 'bullets'})
						ent:set('vehiclebullets',false,true)
					else
						lib.notify({
							description = 'You did not find anything',
							type = 'error'
						})
					end
				end
			end
		end
	else
		lib.hideTextUI()
    end
end)

RegisterNUICallback('close',function()
	SetNuiFocus(false,false)
end)

CreateFile = function(data,slot)
	local input = lib.inputDialog('Report Info: ', {
		{type = 'input', label = 'Victims Full Name: ', required = true},
		{type = 'textarea', label = 'Description of Enclosed Evidence:', icon = 'hashtag'},
		{type = 'textarea', label = 'Description of Offense:', icon = 'hashtag'},
		{type = 'number', label = 'Case #', default = 0},
		{type = 'textarea', label = 'Remarks', default = ''},
	})
	local success = lib.callback.await('renzu_evidence:Identify', false, input,data,slot)
	if success then
		lib.notify({
			description = 'Evidence Report has been Created',
			type = 'success'
		})
	end
end

CreateReport = function()
	local items = GetInventoryItems('evidence')
	local options = {}
	for k,v in pairs(items) do
		if not v.metadata.evidence then
			table.insert(options, {
				title = v.metadata.label,
				description = 'Type: '..v.metadata.type..' \n Date of collection: '..v.metadata.time,
				icon = 'file',
				onSelect = function()
					Citizen.CreateThreadNow(function()
						CreateFile(v.metadata,v.slot)
					end)
				end,
				arrow = true,
			})
		end
	end
	lib.registerContext({
		id = 'identify',
		title = 'Create Evidence Report',
		options = options
	})
	lib.showContext('identify')
end

CreatePoints = function(data,index)
	local onSelect = function()
		if data.type == 'stash' then
			OpenStash('file_locker_'..index)
		else
			CreateReport()
		end
	end
	if config.target then
		Target(data,onSelect)
		return
	end
	function onEnter(self)
		lib.showTextUI('[E] - '..data.label)
	end
	
	function onExit(self)
		lib.hideTextUI()
	end
	
	function inside(self)
		if IsControlJustReleased(0,38) and PlayerData?.job?.name and config.jobs[PlayerData?.job?.name] then
			onSelect()
		end
	end
	
	local box = lib.zones.box({
		coords = data.coord,
		size = vec3(1.5, 1.5, 1.5),
		rotation = 45,
		debug = false,
		inside = inside,
		onEnter = onEnter,
		onExit = onExit
	})
end

Citizen.CreateThreadNow(function()
	for k,v in pairs(config.points) do
		CreatePoints(v)
	end
	for k,v in pairs(config.evidencelocker) do
		CreatePoints(v,k)
	end
end)