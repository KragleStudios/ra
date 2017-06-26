local itertools = {}

-- itertools.zip - iterates over a set of lists in a zip like fashion
function itertools.zip(a, ...)
	if a == nil then return noop end

	local i = 0
	local n = #a
	local _nextIter = itertools.zip(...)

	return function()
		i = i + 1
		if i <= n then return a[n], _nextIter() end
	end
end

-- itertools.chain
function itertools.chain(...)
  local iters = {...}
  local n = 1
  function helperIter(...)
    local a, b, c, d = iters[n]
    if a == nil then
      n = n + 1
      if n > #iters then return nil end
      return helperIter()
    end
  end
end

-- itertools.filter - filter function. Note this supports at most iterators over two values
function itertools.filter(func, iterable)
  return function()
    local a, b
    repeat
      a, b = iterable()
    until a == nil or func(a, b)
    return a, b
  end
end

-- itertools.map - a function for maps over arrays.
function itertools.map(func, iterable)
  return function()
    local a, b = iterable()
    if a == nil then return end
    return func(a, b)
  end
end

-- itertools.select - calls select(n, ...) for every value returned by the iterator
function itertools.select(n, iterable)
  return function()
    return select(n, iterable())
  end
end

-- itertools.list
function itertools.list(func, iterable)
  local list = {}
  local n = 1
  for a in iterable do
    list[n] = a
    n = n + 1
  end
  return list
end
