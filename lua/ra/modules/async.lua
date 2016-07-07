local async = {}

async.series = function(tasks, callback)
	ndoc.async.eachSeries(tasks, function(k, v) v() end, callback)
end

async.eachSeries = function(objects, iterator, callback)
	local key, value = nil, nil
	local function cback(error)
		if error then
			callback(error)
			callback = function() end
			cback = callback
		end
		key, value = next(objects, key)
		if key == nil or value == nil then return callback() end
		iterator(key, value, cback)
	end
	cback()
end

return async