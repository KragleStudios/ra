local xfn = {}

function xfn.noop() end local noop = xfn.noop

function xfn.identity(...)
	return ...
end

function xfn.compose(a, b, ...)
	if not b then return a end
	b = xfn.compose(b, ...)
	return function(...)
		return b(a(...))
	end
end

function xfn.iterPairs(a, ...)
	if a == nil then return noop end

	local i = 0
	local n = #a
	local _nextIter = xfn.iteratePairs(...)

	return n, function()
		i = i + 1
		if i <= n then return a[n], _nextIter() end
	end
end

function xfn.zip(...)
	local iter = xfn.iterPairs(...)
	local list = {}
	local count = 1
	
	local function helper(a, ...)
		if a == nil then return false end
		list[count] = {a, ...}
		count = count + 1
		return true
	end

	while helper(iter()) do end

	return list
end

function xfn.deafen( func )
	return function() func() end
end

-- gives no outputs
function xfn.neuter( func )
	return function(...)
		func(...)
	end
end

-- 
-- CURRYING AND STACK MANIPULATION
--
local function memoize(fn)
	return setmetatable({}, {
			__call = function(self, arg)
				if self[arg] then return self[arg] end
				self[arg] = fn(arg)
				return self[arg]
			end
		})
end
xfn.memoize = memoize

local function curry(fn, arguments)
	if arguments == 1 then return fn end
	return function(a)
		return curry(
			function(...)
				return fn(a, ...)
			end,
			arguments - 1)
	end
end xfn.curry = curry

function xfn.applyArgsToCurriedFunction(fn, ...)
	local count = select('#', ...)
	local function h_apply(count, fn, a, ...)
		if count == 0 then return fn end
		return h_apply(count - 1, fn(a), ...)
	end

	return h_apply(select('#', ...), fn, ...)
end

function xfn.bind(fn, ...)
	return xfn.applyArgsToCurriedFunction(
		xfn.curry(fn, select('#', ...) + 1),
		...)
end
xfn.partial = xfn.bind

function xfn.storeArgs(...)
	return xfn.applyArgsToCurriedFunction(
		xfn.curry(xfn.identity, select('#', ...) + 1),
		...)
end

function xfn.mergeStacks(...)
	local stack = xfn.storeArgs(...)
	return stack
end

--
-- FUNCTIONAL UTILITIES
--

-- returns fn returns arg == value
function xfn.add(a, b)
	return a + b
end
function xfn.mult(a, b)
	return a * b
end
function xfn.sub(a, b)
	return a - b
end
function xfn.div(a, b)
	return a / b
end
function xfn.collapse(a) return a end


return xfn