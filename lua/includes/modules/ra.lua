if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("ra/load_sh.lua")
end

ra = include("ra/load_sh.lua")
