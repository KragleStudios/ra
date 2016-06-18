local oop = {}

oop.class = function(...)
	local methods = {}
	for k, obj in ipairs({...}) do
		for k,v in pairs(obj) do
			if not methods[k] then 
				methods[k] = v
			end
		end
	end
	local mt = {
		__index = methods
	}
	return function(tbl)
		return setmetatable(tbl or {}, mt)
	end
end

oop.quick_inherit = function(obj, parent)
	return setmetatable(class, {
			__index = parent
		})
end
