local oop = {}

--
-- class without copying methods from base class
-- 
oop.class = function(baseclass, meta)
	if not meta then
		meta = baseclass 
		baseclass = nil
	end

	local meta_mt = {}
	local class_mt = {
		__index = meta 
	}

	if baseclass then
		meta.BaseClass = baseclass 
		meta_mt.__index = baseclass 
	end

	setmetatable(meta, meta_mt)

	meta_mt.__call = function(self, ...)
		return setmetatable({}, class_mt):ctor(...)
	end
end

-- 
-- class with copying methods from baseclass
--

oop.fast_class = function(baseclass, meta)
	if not meta then
		meta = baseclass 
		baseclass = nil
	end

	local class_mt = {
		__index = meta 
	}

	if baseclass then 
		meta.BaseClass = baseclass
		for k,v in pairs(baseclass)
			if not meta[k] then
				meta[k] = v
			end
		end
	end 

	setmetatable(meta, {
		__call = function(self, ...)
			return setmetatable({}, class_mt):ctor(...)
		end,
	})

	return meta 
end