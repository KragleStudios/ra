local src_name_cache = {}
local color_cache = {}

local function print(...)
	local src = debug.getinfo(2, 'S')
	if not src_name_cache[src.short_src] then
		src_name_cache[src.short_src] = string.GetFileFromFilename(src.short_src)
	end
	if not color_cache[src.short_src] then
		color_cache[src.short_src] = HSVToColor(math.random(0, 10000000), 1, 1)
	end

	MsgC(color_cache[src.short_src], src_name_cache[src.short_src] .. ':' .. src.linedefined .. ' ')
	_G.print(...)
end

return print