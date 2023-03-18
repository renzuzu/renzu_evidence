if not QBCORE then return end

GetPlayerFromId = function(src)
	local xPlayer = QBCORE.Functions.GetPlayer(src)
	if not xPlayer then return end
	
	if xPlayer.identifier == nil then
		xPlayer.identifier = xPlayer.PlayerData.citizenid
	end

	xPlayer.getMoney = function(value)
		return xPlayer.PlayerData.money['cash']
	end

	xPlayer.removeMoney = function(value)
		xPlayer.Functions.RemoveMoney('cash',tonumber(value))
		return true
	end
	xPlayer.name = xPlayer.PlayerData.charinfo.firstname

	xPlayer.addMoney = function(value)
		return xPlayer.Functions.AddMoney('cash',tonumber(value))
	end
	return xPlayer
end

QBCORE.Functions.CreateUseableItem('evidence', function(source, item)
	local src = source
	local Player = GetPlayerFromId(src)
	TriggerClientEvent("renzu_evidence:useItem", src,item)
end)

FetchPlayerData = function(identifier)
	local data = db.query('players', '*' ,'citizenid', identifier)
	local charinfo = json.decode(data[1].charinfo)
	return {
		firstname = charinfo.firstname,
		lastname = charinfo.lastname,
		dateofbirth = charinfo.birthdate,
		job = json.decode(data[1].job).name,
	}
end