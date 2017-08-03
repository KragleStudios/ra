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

async.eachParallel = function(tasks, callback)
	local pendingCompletion = #tasks
	local results = {}
	for k, task in pairs(tasks) do
		local completed = false
		task(function(data)
			if completed then return end
			results[k] = data
			completed = true
			pendingCompletion = pendingCompletion - 1
			if pendingCompletion == 0 then
				callback(results)
			end
		end)
	end
end

return async
