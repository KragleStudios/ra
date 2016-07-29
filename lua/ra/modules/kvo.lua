local kvo = {}

local kWILDCARD = {}

-- create a new key value observable table
local kvo_mt_lower = {}

kvo_mt.__index = function(self, key)
  return self._real[key]
end

kvo_mt.__newindex = function(self, key, value)
  self._real[key] = value
  if self._observers[kWILDCARD] then
    for k, fn in pairs(self._observers[kWILDCARD]) do
      fn(key, value)
    end
  end
  if self._observers[key] then
    for k, fn in pairs(self._observers[kWILDCARD]) do
      fn(key, value)
    end
  end
end

local kvo_mt_upper = setmetatable({}, {__index = kvo_mt_lower})
function kvo_mt_upper:observe(key, id, fn, a, b, ...)
  if a ~= nil and b == nil then
    self._observers[key][id] = fn
  elseif a ~= nil and b ~= nil then
    self._observers[key][id] = function(key, value)
      -- TODO: automagically propogate observers
    end
  end
end

function kvo.newKVOTable()
  return setmetatable({_real = {}, _observers = {}}, kvo_mt)
end
