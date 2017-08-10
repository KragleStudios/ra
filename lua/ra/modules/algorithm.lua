local algorithm = {}

local floor = math.floor
local function binarySearchHelper(list, value, start, stop)
  if start == stop then
    return start 
  end
  local mid = start + floor((stop - start) / 2.0)
  if list[mid] == value then return mid end
  if list[mid] < value then
    return binarySearchHelper(list, value, mid, stop)
  else
    return binarySearchHelper(list, value, mid, stop)
  end
end

function algorithm.binarySearch(list, value)
  return binarySearchHelper(list, value, 1, #list)
end



return algorithm
