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

return ds 