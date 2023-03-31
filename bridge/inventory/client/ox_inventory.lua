if GetResourceState('ox_inventory') ~= 'started' then return end

OpenStash = function(id,identifier)
    TriggerEvent('ox_inventory:openInventory', 'stash', {id = id, name = 'Evidence Storage', slots = 70, weight = 70000, coords = GetEntityCoords(cache.ped)})
end

GetInventoryItems = function(name)
	return exports.ox_inventory:Search('slots', name)
end

AddEventHandler('ox_inventory:currentWeapon', function(cw)
	local evidence = GlobalState.Evidence
	currentweapon = cw
	if not cw then return end
	local isjob = config.jobs[PlayerData?.job?.name]
	while currentweapon and currentweapon.hash == cw.hash do
		Wait(5)
		local coord = GetEntityCoords(cache.ped)
		if not isjob and IsPedShooting(cache.ped) and cd['bullets'] < GetGameTimer() and math.random(1,100) <= config.chances['bullets'] then
			local _, bullet, _ = RayCastGamePlayCamera(weapon, 200.0,1)
			cd['bullets'] = GetGameTimer() + config.cooldowns['bullets']
			if config.WeaponSerialOnly and not currentweapon?.metadata?.serial then return end
			LocalPlayer.state:set("bullets", {serial = currentweapon.metadata?.serial, coord = vec3(bullet.x,bullet.y,bullet.z), weapon = cw.label, location = GetStreetNames(cache.ped)},true)
		end
		if not isjob and IsPedReloading(cache.ped) and cd['magazine'] < GetGameTimer() and math.random(1,100) <= config.chances['magazine'] then
			print('reloading')
			cd['magazine'] = GetGameTimer() + config.cooldowns['magazine']
			LocalPlayer.state:set("magazine", {serial = currentweapon.metadata?.serial, coord = coord, weapon = cw.label, location = GetStreetNames(cache.ped)},true)
			Wait(100)
			while IsPedReloading(cache.ped) do Wait(1) end
		end
		if currentweapon and currentweapon.hash == `WEAPON_FLASHLIGHT` and isjob then
			local textui = false
			local _, z = GetGroundZFor_3dCoord(coord.x,coord.y,coord.z+2.0,false)
			while IsPlayerFreeAiming(PlayerId()) do
				Wait(1)
				coord = GetEntityCoords(cache.ped)
				for type_,data in pairs(evidence or {}) do
					for k,v in pairs(data) do
						local indist = #(v.coord - coord) < 1.2
						if indist and not textui then
							textui = true
							lib.showTextUI('[E] - Pick evidence ('..type_..')', {
								position = "top-right",
								icon = 'hand',
								style = {
									borderRadius = 0,
									backgroundColor = '#48BB78',
									color = 'white'
								}
							})
						end
						if indist and not v.invehicle then
							if IsControlJustReleased(0,38) then
								TakeEvidence({info = v, type = type_, index = k})
								Wait(2000)
								evidence = GlobalState.Evidence
							end
						end
						if indist then
							DrawMarker(0,v.coord.x,v.coord.y,z+0.25,0.0,180.0,180.0,0,180.0,180.0,0.35,0.35,0.5,255,55,11,55,false,true,2, nil, nil, false)
						end
						if #(v.coord - coord) < 15 then
							DrawMarker(3,v.coord.x,v.coord.y,z+0.25,0.0,180.0,180.0,0,180.0,180.0,0.15,0.15,0.2,66,135,245,255,true,true,2, nil, nil, false)
						end
					end
				end
			end
			if textui then
				lib.hideTextUI()
				evidence = GlobalState.Evidence
			end
			textui = false
		end
	end
end)

exports('useItem', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		if data.name == 'fingerprintkit' then
			if IsPedInAnyVehicle(cache.ped) then
				local vehicle = GetVehiclePedIsIn(cache.ped)
				lib.progressBar({
					duration = 5000,
					label = 'Searching Fingerprints',
					useWhileDead = false,
					canCancel = false,
				})
				local ent = Entity(vehicle).state
				local net = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(cache.ped))
				if ent.fingerprint then
					TakeEvidence({info = ent.fingerprint.info, plate = ent.fingerprint.plate, entity = net, type = 'fingerprint'})
				elseif ent.vehiclebullets then
					TakeEvidence({info = ent.vehiclebullets.info, plate = ent.vehiclebullets.plate, entity = net, type = 'bullets'})
				else
					lib.notify({
						description = 'You did not find anything',
						type = 'error'
					})
				end
				return false
			end
		else
			if not data.metadata.evidence then return end
			if data then
				SendNUIMessage({
					show = true,
					data = data.metadata
				})
				SetNuiFocus(true,true)
			end
		end
	end)
end)