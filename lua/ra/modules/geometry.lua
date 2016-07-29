local geom = {}

geom.polygon = ra.include_sh 'ra/modules/geometry/polygon.lua'
geom.vectorlight = ra.include_sh 'ra/modules/geometry/vectorlight.lua'


local math_sqrt = math.sqrt 
local setmetatable = setmetatable

--
-- A POINT OBJECT
--
local point_mt = {}
point_mt.__index = point_mt 

point_mt.__eq = function(self, other)
	if #self ~= #other then error 'attempt to compair points of different dimensionalities' end
	for i = 1, #self do
		if self[i] ~= other[i] then return false end
	end
	return true 
end

point_mt.__lt = function(self, other)
	if #self ~= #other then error 'attempt to compair points of different dimensionalities' end
	for i = 1, #self do
		if self[i] < other[i] then return true end
	end
	return false 
end

point_mt.__le = function(self, other)
	if #self ~= #other then error 'attempt to compair points of different dimensionalities' end
	for i = 1, #self do
		if self[i] <= other[i] then return true end
	end
	return false 
end

point_mt.__add = function(self, other)
	if #self ~= #other then error 'attempt to add points of different dimensionalities' end 
	local function addHelper(a, b, i, c)
		if i > c then return end 
		return a[i] + b[i], addHelper(a, b, i + 1, c)
	end
	return setmetatable({addHelper(self, other, 1, #self)}, point_mt)
end

point_mt.__sub = function(self, other)
	if #self ~= #other then error 'attempt to subtract points of different dimensionalities' end 
	local function subHelper(a, b, i, c)
		if i > c then return end 
		return a[i] - b[i], subHelper(a, b, i + 1, c)
	end
	return setmetatable({subHelper(self, other, 1, #self)}, point_mt)
end

point_mt.__mul = function(self, other)
	if getmetatable(other) == point_mt then 
		if #self ~= #other then error 'attempt to multiply points of different dimensionalities' end 
		local function mulHelper(a, b, i, c)
			if i > c then return end
			return a[i] * b[i], mulHelper(a, b, i + 1, c)
		end
		return setmetatable({mulHelper(self, other, 1, #self)}, point_mt)
	else 
		local function mulHelper(a, b, i, c)
			if i > c then return end
			return a[i] * b, mulHelper(a, b, i + 1, c)
		end
		return setmetatable({mulHelper(self, other, 1, #self)}, point_mt)
	end
end

point_mt.__div = function(self, other)
	local function divHelper(a, b, i, c)
		if i > c then return end
		return a[i] / b, divHelper(a, b, i + 1, c)
	end
	return setmetatable({divHelper(self, other, 1, #self)}, point_mt)
end

point_mt.__tostring = function(self, other)
	return '(' .. table.concat(self, ', ') .. ')'
end

function point_mt:getX()
	return self[1]
end

function point_mt:getY()
	return self[2]
end

function point_mt:getZ()
	return self[3]
end

function point_mt:getW()
	return self[4]
end

function point_mt:distToSqr(point2)
	if #self ~= #point2 then error 'attempt to find distance between two points of different dimensionalities' end
	local sum = 0
	for i = 1, #self do
		sum = sum + (self[i] - point2[i]) * (self[i] - point2[i])
	end
	return sum
end 

function point_mt:distTo(point2)
	return math_sqrt(self:distToSqr(point2))
end

function point_mt:length()
	local sum = 0
	for i = 1, #self do
		sum = sum + self[i] * self[i]
	end
	return math_sqrt(sum)
end

function point_mt:normalize()
	return self / self:length()
end

function point_mt:unpack()
	return unpack(self)
end

function geom.point(...)
	return setmetatable({...}, point_mt)	
end

function geom.unpackPoints(...)
	local points = {...}
	local function unpackHelper(pcount, pindex, icount, iindex)
		if iindex > icount then
			if pindex == pcount then return nil end 
			return unpackHelper(pcount, pindex + 1, #points[pindex + 1], 1)
		end
		return points[pindex][iindex], unpackHelper(pcount, pindex, icount, iindex + 1)
	end
	return unpackHelper(#points, 1, #points[1], 1)
end

--
-- TRIANGLES
--
local triangle_mt = {}
function triangle_mt:ctor(p1, p2, p3)
	
	self.p1 = p1 
	self.p2 = p2 
	self.p3 = p3 

	local x1, y1 = p1[1], p1[2]
	local x2, y2 = p2[1], p2[2]
	local x3, y3 = p3[1], p3[2]

	-- compute the transformation to the unit triangle
	local a1, b1 = x2 - x1, x3 - x1
	local c1, d1 = y2 - y1, y3 - y1
	local det = a1 * d1 - b1 * c1 
	local a, b = d1/det, -b1/det
	local c, d = -c1/det, a1/det

	self.isPointInside = function(self, x, y)
		-- translate to the origin
		x, y = x - x1, y - y1
		-- apply the transformation matrix
		x, y = a * x + b * y, c * x + d * y
		
		return x >= 0 and y >= 0 and x + y <= 1 
	end
end

function triangle_mt:isPointInside(x, y)
	return false 
end

triangle_mt.__index = triangle_mt

function geom.createTriangle(p1, p2, p3)
	local obj = setmetatable({}, triangle_mt)
	obj:ctor(p1, p2, p3)
	return obj 
end


function geom.triangulatePolygon(...)
	local polygon = geom.polygon(geom.unpackPoints(...))
	local triangles = polygon:triangulate()
	
	for k,v in ipairs(triangles) do
		triangles[k] = geom.createTriangle(
				geom.point(v.vertices[1].x, v.vertices[1].y),
				geom.point(v.vertices[2].x, v.vertices[2].y),
				geom.point(v.vertices[3].x, v.vertices[3].y)
			)
	end

	return triangles
end


--
-- LINES
--
local edge_mt = {}
edge_mt.__index = edge_mt

function edge_mt:intersectWith(other, ignoreLength)
	local l1x1 = self[1][1]
	local l1y1 = self[1][2]
	local l1x2 = self[2][1]
	local l1y2 = self[2][2]

	local l2x1 = other[1][1]
	local l2y1 = other[1][2]
	local l2x2 = other[2][1]
	local l2y2 = other[2][2]

	local d = (l2y2 - l2y1) * (l1x2 - l1x1) - (l2x2 - l2x1) * (l1y2 - l1y1)

	-- this happens if hte lines are parallel
	if d == 0 then return 0 end 

	local n_a = (l2x2 - l2x1) * (l1y1 - l2y1) - (l2y2 - l2y1) * (l1x1 - l2x1)
	local n_b = (l1x2 - l1x1) * (l1y1 - l2y1) - (l1y2 - l1y1) * (l1x1 - l2x1)

	-- compute the fractional points of intersection
	local ua = n_a / d 
	local ub = n_b / d 

	if ignoreLength or (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1) then 
		return true, l1x1 + (ua * (l1x2 - l1x1)), l1y1 + (ua * (l1y2 - l1y1))
	end
	return false
end

function geom.edge(p1, p2)
	return setmetatable({p1, p2}, edge_mt)
end

local p1 = geom.point(12, 13, 47)
local p2 = geom.point(31, 23, 22)

return geom