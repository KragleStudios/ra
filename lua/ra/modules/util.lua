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

return util