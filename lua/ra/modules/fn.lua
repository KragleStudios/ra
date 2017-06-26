local fn = {}

function fn.noop() end local noop = fn.noop

function fn.identity(...)
	return ...
end

function fn.compose(a, b, ...)
	if not b then return a end
	b = fn.compose(b, ...)
	return function(...)
		return b(a(...))
	end
end

function fn.deafen( func )
	return function() func() end
end

-- gives no outputs
function fn.neuter( func )
	return function(...)
		func(...)
	end
end

--
-- CURRYING AND STACK MANIPULATION
--

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
fn.store_stack = store_stack
fn.storeArgs = store_stack -- legacy alias
fn.mergeStacks = store_stack -- legacy alias

local function memoize(fn) -- TODO: create a curried version of memoize
	return setmetatable({}, {
			__call = function(self, arg)
				if self[arg] then return self[arg] end
				self[arg] = fn(arg)
				return self[arg]
			end
		})
end
fn.memoize = memoize

local function curry(fn, arguments)
	if arguments == 1 then return fn end
	return function(a)
		return curry(
			function(...)
				return fn(a, ...)
			end,
			arguments - 1)
	end
end
fn.curry = curry

local function applyArgsToCurriedFunction(fn, a, b, ...)
	if b == nil then
		return fn(a)
	end
	return applyArgsToCurriedFunction(fn(a), b, ...)
end
fn.applyArgsToCurriedFunction = applyArgsToCurriedFunction

function fn.bind(fn, ...)
	local cont = store_stack(...)
	return function(...)
		return fn(cont(...))
	end
end

--
-- FUNCTIONAL UTILITIES
--

-- returns fn returns arg == value
function fn.add(a, b)
	return a + b
end

function fn.mult(a, b)
	return a * b
end

function fn.sub(a, b)
	return a - b
end

function fn.div(a, b)
	return a / b
end

function fn.collapse(a) return a end

function fn.const(a)
	return function()
		return a
	end
end


return fn
