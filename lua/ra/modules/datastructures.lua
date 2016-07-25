local ds = {}

--
-- REDBLACK TREE
-- 
local redblack = ra.include_sh 'ra/modules/datastructures/redblack.lua'
local rbtree_mt = {}
rbtree_mt.__index = rbtree_mt 
function rbtree_mt:insert(value)
	return redblack.insert(self, value)
end

function rbtree_mt:delete(value)
	return redblack.delete(self, value)
end

function rbtree_mt:iterate()
	return redblack.iterate(self)
end 

function rbtree_mt:find(value)
	return redblack.find(self, value)
end

function ds.newRBTree()
	return setmetatable(redblack.newTree(), rbtree_mt)
end

--
-- KEY / VALUE TUPPLE
-- @protocol: totally ordered
-- @desc totally ordered depending only on the first value
--
local kv_mt = {}
kv_mt.__index = kv_mt
kv_mt.__lt = function(self, other)
	return self[1] < other[1]
end
kv_mt.__le = function(self, other)
	return self[1] <= other[1]
end
kv_mt.__eq = function(self, other)
	return self[1] == other[1]
end

function kv_mt:getKey()
	return self[1]
end

function kv_mt:getValue()
	return self[2]	
end

function ds.newKVPair(key, value)
	return setmetatable({key, value}, kv_mt)
end

--
-- nTupple
-- @protocol: totally ordered
--
local ntupple_mt = {}
ntupple_mt.__index = ntupple_mt 
ntupple_mt.__eq = function(self, other)
	if #self ~= #other then return false end 
	for k,v in ipairs(self) do
		if other[k] ~= v then return false end 
	end
	return true
end

ntupple_mt.__lt = function(self, other)
	if #self < #other then return true end
	for k,v in ipairs(self) do
		if self[v] < other[v] then return true end	
	end
	return false
end

ntupple_mt.__le = function(self, other)
	if #self <= #other then return true end
	for k,v in ipairs(self) do
		if self[v] <= other[v] then return true end	
	end
	return false	
end

function ds.nTupple(...)
	return setmetatable({...}, ntupple_mt)
end

return ds 
