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


	if not meta.init then
		meta.init = function(self) return self end
	end
	if not meta.ctor then
		meta.ctor = function() return {} end
	end


	meta_mt.__call = function(self, ...)
		return setmetatable(class_mt:ctor(), class_mt):init(...)
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

	if not meta.init then
		meta.init = function(self) return self end
	end
	if not meta.ctor then
		meta.ctor = function() return {} end
	end

	local class_mt = {
		__index = meta
	}

	if baseclass then
		meta.BaseClass = baseclass
		for k,v in pairs(baseclass) do
			if not meta[k] then
				meta[k] = v
			end
		end
	end

	local metameta_mt = {
		__call = function(self, ...)
			return setmetatable(class_mt:ctor(...), class_mt):init(...)
		end,
	}

	setmetatable(meta, metatable_mt)

	return meta
end
