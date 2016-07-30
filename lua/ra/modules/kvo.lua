local kvo = {}

local select = select 
local getmetatable = getmetatable 

local kWILDCARD = {}
local kASTERIX = {}

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

-- create a new key value observable table
local kvo_mt = {}
kvo_mt.__index = kvo_mt

 local function kvo_newindex(self, key, value)
 	if type(value) == 'table' and getmetatable(value.__real) ~= kvo_mt then
 		value = kvo.newKVOTable(value) -- convert it to a kvo table
 	end 

	self.__real[key] = value
	if self.__observers[kWILDCARD] then
		for k, fn in pairs(self.__observers[kWILDCARD]) do
			fn(key, value, self)
		end
	end
	if self.__observers[key] then
		for k, fn in pairs(self.__observers[key]) do
			fn(value, self)
		end
	end
end

function kvo_mt:_kvo_observe(id, fn, argBuild, a, b, ...)
	if a == nil then return end 

	local realFn
	if b == nil then
		-- it is a primary observer and therefore should invoke a call to fn
		realFn = function(...)
			fn(argBuild(...))
		end
	else
		print("adding an intermediate observer on ", a)
		local restOfPath = store_stack(...)

		if a == kWILDCARD then
			-- propogate the observer having 'fild the wild card' into the arg build
			realFn = function(key, value)
				if type(value) == 'table' and getmetatable(value.__real) == kvo_mt then
					value:_kvo_observe(id, fn, store_stack(argBuild(key)), b, restOfPath())
				end
			end 
		else
			-- propogate the observer
			realFn = function(value)
				if type(value) == 'table' and getmetatable(value.__real) == kvo_mt then
					value:_kvo_observe(id, fn, argBuild, b, restOfPath())
				end
			end
		end
	end

	if not self.__observers[a] then self.__observers[a] = {} end 
	self.__observers[a][id] = realFn

	if a == kWILDCARD then
		for k,v in pairs(rawget(self, '__real')) do
			realFn(k, v, self)
		end 
	elseif rawget(self, '__real')[a] ~= nil then
		realFn(self[a], self)
	end
end

function kvo_mt:kvo_observe(id, fn, ...)
	self:_kvo_observe(id, fn, function(...) return ... end, ...)
end

function kvo.newKVOTable(table)
	local real = setmetatable({}, kvo_mt)
	if table then
		for k,v in pairs(table) do
			real[k] = v 
		end 
	end

	return setmetatable({__real = real, __observers = {}}, {
			__index = real,
			__newindex = kvo_newindex 
		})
end

return kvo
