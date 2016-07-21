local util = {}

local function max(a, b, ...)
	if b == nil then return a end
	b = max(b, ...)
	return a > b and a or b
end

local function min(a, b, ...)
	if b == nil then return a end
	b = min(b, ...)
	return a < b and a or b
end

util.min = min
util.max = max

function util.extend(tbl, values)
	local newTbl = {}
	for k,v in pairs(values) do
		newTbl[k] = v
	end
	for k,v in pairs(tbl) do
		newTbl[k] = v
	end
	return newTbl
end

function util.filter(tab, func)
	local c = 1
	for i = 1, #tab do
		if func(tab[i]) then
			tab[c] = tab[i]
			c = c + 1
		end
	end
	for i = c, #tab do
		tab[i] = nil
	end
	return tab
end

function util.map( tbl, func )
	for k,v in pairs( tbl )do
		tbl[k] = func( v, k );
	end
	return tbl;
end

function util.reduce(tbl, initial, func)
	local last = initial
	for k, v in ipairs(tbl) do
		last = func(v, initial)
	end
	return last
end


local scales = {
	["s"] = 1, -- Second
	["min"] = 60, -- Minute
	["h"] = 3600, -- Hour
	["d"] = 86400, -- Day
	["w"] = 604800, -- Week 
	["m"] = 2628000, -- Month
	["y"] = 31536000, -- Year
	["ly"] = 31622400, -- Leap Year
	["dec"] = 315360000, -- Decade
	["mil"] = 31536000000, -- Millenium
	["eon"] = 157680000000000 -- Eon
}

function util.timestring(str)
	local time = 0
	str = str:gsub("%s+", "") -- Trim spaces etc.
	for amt, scl in str:gmatch( "(%d+)(%a+)") do
		if scales[scl] then
			time = time + (scales[scl] * amt)
		end
	end
	if time == 0 then -- Eh doesnt look clean :( but I dont want to return a 0
		return false
	end
	return (time / 60)
end

return util