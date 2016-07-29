local kvo = {}

local kWILDCARD = {}
local kASTERIX = {}

-- store stack in pure lua
local _stack_store = {}
_stack_store[0] = function() return function() end end
_stack_store[1] = function(a) return function() return a end end 
_stack_store[2] = function(a, b) return function() return a, b end end 
_stack_store[3] = function(a, b, c) return function() return a, b, c end end 
_stack_store[4] = function(a, b, c, d) return function() return a, b, c, d end end 
_stack_store[5] = function(a, b, c, d, e) return function() return a, b, c, d, e end end 
_stack_store[6] = function(a, b, c, d, e, f) return function() return a, b, c, d, e, f end end 
_stack_store[7] = function(a, b, c, d, e, f, g) return function() return a, b, c, d, e, f, g end end
_stack_store[8] = function(a, b, c, d, e, f, g, h) return function() return a, b, c, d, e, f, g, h end end
local function store_stack(...)
  local c = select('#', ...)
  if store_stack[c] then 
    return store_stack[c](...)
  else
    local cur = store_stack(...)
    local next = store_stack(select(9, ...))
    return function(...)
      return cur(next(...))
    end
  end

  return c  
end

-- create a new key value observable table
local kvo_mt_lower = {}
kvo_mt_lower.__index = function(self, key)
  return self._real[key]
end

local kvo_mt_upper = setmetatable({}, {__index = kvo_mt_lower})
kvo_mt_upper.__newindex = function(self, key, value)
  self._real[key] = value
  if self._observers[kWILDCARD] then
    for k, fn in pairs(self._observers[kWILDCARD]) do
      fn(key, value)
    end
  end
  if self._observers[key] then
    for k, fn in pairs(self._observers[key]) do
      fn(value)
    end
  end
end

function kvo_mt_upper:_observe(id, fn, argBuild, a, b, ...)
  if a ~= nil and b == nil then
    -- it is a primary observer and therefore should invoke a call to fn
    self._observers[a][id] = function(...)
      fn(argBuild(...))
    end
  elseif a ~= nil and b ~= nil then
    if a == kWILDCARD then
      -- propogate the observer having 'fild the wild card' into the arg build
      self._observers[a][id] = function(key, value)
        if getmetatable(value) == kvo_mt_upper then
          value:_observe(id, fn, store_stack(argBuild(key)), b, ...)
        end
      end
    else
      -- propogate the observer
      self._observers[a][id] = function(value)
          if getmetatable(value) == kvo_mt_upper then
            value:_observe(id, fn, argBuild, b, ...)
          end
        end
      end
  end
end

function kvo_mt_upper:observe(id, fn, ...)
  self:_observe(id, fn, function() end, ...)
end

function kvo.newKVOTable()
  return setmetatable({_real = {}, _observers = {}}, kvo_mt)
end
