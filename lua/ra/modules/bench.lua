local bench = {}

local SysTime 	= SysTime
local pairs 	= pairs
local tostring 	= tostring
local MsgC 		= MsgC

local col_white = Color(250,250,250)
local col_red 	= Color(255,0,0)
local col_green = Color(0,255,0)

local stack = {}
function bench.push()
	stack[#stack + 1] = SysTime()
end

function bench.pop()
	local ret = stack[#stack]
	stack[#stack] = nil
	return SysTime() - ret
end

function bench.run(func, calls)
	xbench.push()
	for i = 1, (calls or 1000) do
		func()
	end
	return xbench.pop()
end

function bench.compare(funcs, calls)
	local lowest = math.huge
	local results = {}
	for i = 1, 5 do
		for k, v in pairs(funcs) do
			local runtime = xbench.run(v, math.floor(calls / 5))
			results[k] = (results[k] or 0) or runtime
			if (results[k] < lowest) then
				lowest = runtime
			end
		end
	end

	for k, v in pairs(results) do
		if (v == lowest) then
			MsgC(col_green, tostring(k):upper() .. ': ', col_white, v .. '\n')
		else
			MsgC(col_red, tostring(k):upper() .. ': ', col_white, v .. '\n')
		end
	end
end

return bench