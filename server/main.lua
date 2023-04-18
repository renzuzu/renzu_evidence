
local sql = setmetatable({},{
	__call = function(self)
		self.query = function(name, column, where, string)
			local str = 'SELECT %s FROM %s WHERE %s = ?'
			return MySQL.query.await(str:format(column,name,where),{string})
		end
		return self
	end
})

db = sql()

if not GlobalState.Evidence then
	GlobalState.Evidence = {}
end
if not GlobalState.Bloods then
	GlobalState.Bloods = {}
end

local identifiers = {}
GetPlayerIdentifier = function(src)
	if not identifiers[src] then
		local xPlayer = GetPlayerFromId(src)
		identifiers[src] = xPlayer.identifier
	end
	return identifiers[src]
end

AddStateBagChangeHandler('bullets' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	if not value then return end
    local src = tonumber(bagName:gsub('player:', ''), 10)
    local evidence = GlobalState.Evidence
	local identifier = GetPlayerIdentifier(src)
	if not identifier then return end
	if not evidence.bullets then evidence.bullets = {} end
	table.insert(evidence.bullets,{serialid = value.serial, coord = value.coord, weapon = value.weapon, identifier = identifier, time = os.date("%Y-%m-%d %H:%M:%S"), location = value.location, invehicle = value.invehicle})
	GlobalState.Evidence = evidence
end)

AddStateBagChangeHandler('magazine' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	print(value,'magazine')
	if not value then return end
    local src = tonumber(bagName:gsub('player:', ''), 10)
    local evidence = GlobalState.Evidence
	local identifier = GetPlayerIdentifier(src)
	if not identifier then return end
	if not evidence.magazine then evidence.magazine = {} end
	table.insert(evidence.magazine,{serialid = value.serial, coord = value.coord, weapon = value.weapon, identifier = identifier, time = os.date("%Y-%m-%d %H:%M:%S"), location = value.location, ts = os.time()})
	GlobalState.Evidence = evidence
end)

AddStateBagChangeHandler('bloods' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	if not value then return end
    local src = tonumber(bagName:gsub('player:', ''), 10)
    local evidence = GlobalState.Evidence
	local identifier = GetPlayerIdentifier(src)
	if not identifier then return end
	if not evidence.bloods then evidence.bloods = {} end
	table.insert(evidence.bloods,{coord = value.coord, identifier = identifier, time = os.date("%Y-%m-%d %H:%M:%S"), location = value.location, ts = os.time()})
	GlobalState.Evidence = evidence
end)

AddStateBagChangeHandler('vehiclefragments' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	if not value then return end
    local src = tonumber(bagName:gsub('player:', ''), 10)
    local evidence = GlobalState.Evidence
	local identifier = GetPlayerIdentifier(src)
	if not identifier then return end
	if not evidence.vehiclefragments then evidence.vehiclefragments = {} end
	table.insert(evidence.vehiclefragments,{plate = value.plate, coord = value.coord, identifier = identifier, time = os.date("%Y-%m-%d %H:%M:%S"), location = value.location, ts = os.time()})
	print("vehiclefragments")
	GlobalState.Evidence = evidence
end)

lib.callback.register('renzu_evidence:removeevidence', function(src,data)
	local evidence = GlobalState.Evidence
	local xPlayer = GetPlayerFromId(src)
	local label = data.type == 'bullets' and 'Bullet Catridge' or data.type == 'magazine' and 'Empty Magazine' or data.type == 'bloods' and 'Blood clot' or data.type == 'fingerprint' and 'Fingerprint Sample' or data.type == 'vehiclefragments' and 'Vehicle Fragment'
	local image = data.type == 'bullets' and 'ammo-9' or data.type == 'magazine' and 'magazine' or data.type == 'bloods' and 'blood' or data.type == 'fingerprint' and 'fingerprint' or data.type == 'vehiclefragments' and 'vehiclefragments'
	local metadata = {serialid = data.info.serialid, plate = data.info.plate, recoveredby = xPlayer.name, type = data.type, label = label, description = 'unidentified '..data.type, location = data.info.location, time = data.info.time or os.date("%Y-%m-%d %H:%M:%S"), identifier = data.info.identifier, image = image}
	local item = evidence[data.type]
	if data.type ~= 'fingerprint' then
		AddItem(src, 'evidence', 1, metadata)
		if item[data.index] then
			evidence[data.type][data.index] = nil
			GlobalState.Evidence = evidence
		elseif data.entity then
			Entity(NetworkGetEntityFromNetworkId(data.entity)).state:set('vehiclebullets',false,true)
		end
	elseif data.type == 'fingerprint' then
		AddItem(src, 'evidence', 1, metadata)
		Entity(NetworkGetEntityFromNetworkId(data.entity)).state:set('fingerprint',false,true)
	end
end)

lib.callback.register('renzu_evidence:Identify', function(src,data,metadata,slot)
	local evidence = GlobalState.Evidence
	local xPlayer = GetPlayerFromId(src)
	if not metadata then return false end
	--local evidence = MySQL.query.await('SELECT * FROM renzu_evidence')
	local num = math.random(69,69999)
	local fetchplayer = FetchPlayerData(metadata.identifier)
	local firstname = fetchplayer.firstname or ''
	local lastname = fetchplayer.lastname or ''
	local person = firstname..' '..lastname
	local report = {
		label = 'Evidence #'..tostring(num),
		description = 'Suspect: '..person..' Date: '..metadata.time,
		evidence = true,
		evidenceid = num,
		type = metadata.type,
		location = metadata.location,
		time = metadata.time,
		name = metadata.label,
		person = person,
		dateofbirth = fetchplayer.dateofbirth,
		occupation = fetchplayer.job,
		submit_by = xPlayer.name,
		recoveredby = metadata.recoveredby,
		description_evidence = data[2] or 'Undisclosed',
		description_offense = data[3] or 'Undisclosed',
		victim = data[1] or 'Unidentified',
		case = data[4] or 'none',
		remarks = data[5] or 'none',
		sealed_time = os.date("%Y-%m-%d %H:%M:%S"),
		plate = metadata.plate,
		serialid = metadata.serialid
	}
	AddItem(src, 'evidence', 1, report)
	return report
end)

Citizen.CreateThread(function() -- evidence expiration timer
	while true do
		Wait(60000)
		local evidence = GlobalState.Evidence
		for type,data in pairs(evidence) do
			for index,v in pairs(data) do
				if v?.ts and (os.time() - v.ts) > config.expiration then
					evidence[type][index] = nil
				end
			end
		end
		GlobalState.Evidence = evidence
	end
end)

AddEventHandler("playerDropped",function()
	local source = source
	if identifiers[source] then identifiers[source] = nil end
end)

Citizen.CreateThreadNow(function()
	if GetResourceState('ox_inventory') ~= 'started' then return end
	for k,v in pairs(config.evidencelocker) do
		exports.ox_inventory:RegisterStash('file_locker_'..k, 'Storage', 90, 1000000, false)
	end
end)