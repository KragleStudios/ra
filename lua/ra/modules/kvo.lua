local kvo = {}

local select = select
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type
local ipairs, pairs = ipairs, pairs

local kWILDCARD = {}
local kASTERIX = {}
kvo.kWILDCARD = kWILDCARD
kvo.kASTERIX = kASTERIX -- TODO: implement this


-- store stack in pure lua
local _stack_store = {}
_stack_store[0] = function() return function(...) return ... end end
_stack_store[1] = function(a) return function(...) return a, ... end end
_stack_store[2] = function(a, b) return function(...) return a, b, ... end end
_stack_store[3] = function(a, b, c) return function(...) return a, b, c, ... end end
_stack_store[4] = function(a, b, c, d) return function(...) return a, b, c, d, ... end end
_stack_store[5] = function(a, b, c, d, e) return function(...) return a, b, c, d, e, ... end end
_stack_store[6] = function(a, b, c, d, e, f) return function(...) return a, b, c, d, e, f, ... end end
_stack_store[7] = function(a, b, c, d, e, f, g) return function(...) return a, b, c, d, e, f, g, ... end end
_stack_store[8] = function(a, b, c, d, e, f, g, h) return function(...) return a, b, c, d, e, f, g, h, ... end end

local function store_stack(...)
	local c = select('#', ...)
	if _stack_store[c] then
		return _stack_store[c](...)
	else
		local cur = _stack_store[8](...)
		local next = store_stack(select(9, ...))
		return function(...)
			return cur(next(...))
		end
	end
end
kvo.store_stack = store_stack

-- given a formatted path string push the components onto the stack
local function processSymbol(symbol)
	if symbol == '?' then
		return kWILDCARD
	elseif symbol == '*' then
		ErrorNoHalt("WARNING: asterix not yet supported")
		return kASTERIX
	end
	return symbol
end
local function compilePath(path)
	local function compilePathHelper(path, index)
		local next = string.find(path, '.', index, true)
		if next then
			local substr = string.sub(path, index, next - 1)
			return processSymbol(substr), compilePathHelper(path, next + 1)
		end
		local substr = string.sub(path, index)
		return processSymbol(substr)
	end
	return compilePathHelper(path, 1)
end

kvo.compilePath = compilePath

-- handles adding an index to a keyvalue observable table
local function kvo_newindex(self, key, value)
	if type(value) == 'table' and value.__observers == nil then
		value = kvo.newKVOTable(value) -- convert it to a kvo table
	end

	local oldValue = self.__real[key]
	self.__real[key] = value
	if self.__observers[kWILDCARD] then
		for k, fn in pairs(self.__observers[kWILDCARD]) do
			fn(key, value, oldValue, self)
		end
	end
	if self.__observers[key] then
		for k, fn in pairs(self.__observers[key]) do
			fn(value, oldValue, self)
		end
	end
end

local function isObservable(table)
	return table.__observers ~= nil
end

local function observe(table, id, fn, argBuild, a, b, ...)
	if a == nil then return end
	if table.__observers == nil then
		error("kvo error attempt to attach an observer to a non observable object " .. tostring(table))
	end

	local realFn
	if b == nil then
		-- it is a primary observer and therefore should invoke a call to fn
		realFn = function(...)
			fn(argBuild(...))
		end
	else
		local restOfPath = store_stack(...)

		if a == kWILDCARD then
			-- propogate the observer having 'fild the wild card' into the arg build
			realFn = function(key, value)
				if type(value) == 'table' then
					observe(value, id, fn, store_stack(argBuild(key)), b, restOfPath())
				end
			end
		else
			-- propogate the observer
			realFn = function(value)
				if type(value) == 'table' then
					observe(value, id, fn, argBuild, b, restOfPath())
				end
			end
		end
	end

	if not table.__observers[a] then table.__observers[a] = {} end
	table.__observers[a][id] = realFn

	if a == kWILDCARD then
		for k,v in pairs(rawget(table, '__real')) do
			realFn(k, v, v, table)
		end
	elseif rawget(table, '__real')[a] ~= nil then
		realFn(table[a], table[a], table)
	end
end

function kvo.observe(table, id, fn, ...)
	observe(table, id, fn, function(...) return ... end, ...)
end

function kvo.newKVOTable(table)
	local real = setmetatable({}, kvo_mt)
	if table then
		for k,v in pairs(table) do
			if type(v) == 'table' and not v.__observers then
				v = kvo.newKVOTable(v)
			end
			real[k] = v
		end
	end

	return setmetatable({__real = real, __observers = {}}, {
			__index = real,
			__newindex = kvo_newindex
		})
end

function kvo.isObservable(table)
	return table.__observers ~= nil
end

return kvo
