local geom = {}

geom.polygon = ra.include_sh 'ra/modules/geometry/polygon.lua'
geom.vectorlight = ra.include_sh 'ra/modules/geometry/vectorlight.lua'


local math_sqrt = math.sqrt 

--
-- A POINT OBJECT
--
local point_mt = setmetatable({}, {
	__index = function(self, key) 
		if key == 'x' then
			return self[1]
		elseif key == 'y' then
			return self[2]
		end
		return nil
	end
})

point_mt.__index = point_mt
point_mt.__call = function(self)
	return self[1], self[2]
end
point_mt.__eq = function(self, other)
	return self[1] == other[1] and self[2] == other[2]
end
point_mt.__lt = function(self, other)
	if self[1] == other[1] then
		return self[2] < other[2]
	end
	return self[1] < other[1]
end 

point_mt.__le = function(self, other)
	if self[1] == other[1] then
		return self[2] <= other[2]
	end
	return self[1] <= other[1]
end

function point_mt:getX()
	return self[1]
end

function point_mt:getY()
	return self[2]
end

function point_mt:distToSqr(point2)
	local dx = self[1] - point2[1]
	local dy = self[2] - point2[2]
	return dx * dx + dy * dy 
end 

function point_mt:distTo(point2)
	local dx = self[1] - point2[1]
	local dy = self[2] - point2[2]
	return math_sqrt(dx * dx + dy * dy)
end

function geom.point(x, y)
	return setmetatable({x, y}, point_mt)	
end

function geom.unpackPoints(p, ...)
	if not p then return end 
	return p[1], p[2], geom.unpackPoints(...)
end

--
-- TRIANGLES
--
local triangle_mt = {}
function triangle_mt:ctor(p1, p2, p3)
	
	self.p1 = p1 
	self.p2 = p2 
	self.p3 = p3 

	local x1, y1 = p1()
	local x2, y2 = p2()
	local x3, y3 = p3()

	-- compute the transformation to the unit triangle
	local a1, b1 = x2 - x1, x3 - x1
	local c1, d1 = y2 - y1, y3 - y1
	local det = a1 * d1 - b1 * c1 
	local a, b = d1/det, -b1/det
	local c, d = -c1/det, a1/det

	self.isPointInside = function(self, x, y)
		x = x - x1 
		y = y - y1

		x = a * x + b * y 
		y = c * x + d * y

		return x >= 0 and y >= 0 and x + y < 1 
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

return geom