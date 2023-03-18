if GetResourceState('ox_target') == 'started' 
or GetResourceState('ox_target') ~= 'started' and GetResourceState('qb-target') ~= 'started' or not config.target then return end

Target = function(data,cb)
	print('add target',data.label)
	exports['qb-target']:AddBoxZone(data.label, data.coord, 0.75, 0.75, {
		name = data.label,
		debugPoly = false,
		minZ = data.coord.z-0.45,
		maxZ = data.coord.z+0.45,
	}, {
		options = {
			{
				name = data.label,
				action = cb,
				icon = 'fa-solid fa-cube',
				label = data.label,
				canInteract = function(entity)
					return PlayerData?.job?.name and config.jobs[PlayerData?.job?.name] or false
				end,
			}
		},
		distance = 5.5
	})
end