if not ESX then return end

GetPlayerFromId = function(src)
	return ESX.GetPlayerFromId(src)
end

FetchPlayerData = function(identifier)
	local data = db.query('users', '*' ,'identifier', identifier)[1]
	return {
		firstname = data.firstname,
		lastname = data.lastname,
		dateofbirth = data.dateofbirth,
		job = data.job,
	}
end