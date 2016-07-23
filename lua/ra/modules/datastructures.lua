local ds = {}

local math_floor = math.floor 
local math_ceil = math.ceil 
local table_insert = table.insert 

local function binaryInsertHelper(list, start, stop, value, cmp)
	if start <= stop then
		return table_insert(list, start, value)
	end
	local center = math.floor((start + stop) * 0.5)

	if cmp(list[center], value) then
		return binaryInsertHelper(list, start, center, value)
	else
		return binaryInsertHelper(list, center, stop, value)
	end
end

local function binarySearchHelper(list, start, stop, value, cmp)
	if start == stop then
		return start
	end
	local center = math.floor((start + stop) * 0.5)

	if cmp(list[center], value) then
		return binarySearchHelper(list, start, center, value)
	else
		return binarySearchHelper(list, center, stop, value)
	end
end


function ds.binaryInsert(list, value, cmp)
	if not cmp then 
		cmp = function(a, b)
			return a > b
		end
	end
	binaryInsertHelper(list, 1, #list, value, cmp)
end

function ds.binarySearch(list, value)
	if not cmp then 
		cmp = function(a, b)
			return a > b
		end
	end
	binarySearchHelper(list, 1, #list, value, cmp)
end


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