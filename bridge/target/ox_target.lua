if GetResourceState('ox_target') ~= 'started' or not config.target then return end

Target = function(data,cb)
	exports.ox_target:addBoxZone({
		coords = data.coord,
		useZ = true,
		size = vec3(2, 2, 2),
		rotation = 45,
		debug = drawZones,
		options = {
			{
				name = data.label,
				onSelect = cb,
				icon = 'fa-solid fa-cube',
				label = data.label,
				canInteract = function(entity)
					return PlayerData?.job?.name and config.jobs[PlayerData?.job?.name] or false
				end,
			}
		}
	})
end