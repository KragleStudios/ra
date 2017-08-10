_G.ra = {}
print "loading Ra by thelastpenguin"

ra.version = '1.0.0'

ra.include_sv = SERVER and include or function() end
ra.include_cl = CLIENT and include or AddCSLuaFile
ra.include_sh = function(file)
	if SERVER then AddCSLuaFile(file) end
	return include(file)
end

ra.print   = ra.include_sh 'modules/print.lua'
ra.oop     = ra.include_sh 'modules/oop.lua'
ra.util    = ra.include_sh 'modules/util.lua'
ra.fn      = ra.include_sh 'modules/fn.lua'
ra.itertools = ra.include_sh 'modules/itertools.lua'
ra.bench   = ra.include_sh 'modules/bench.lua'
ra.path    = ra.include_sh 'modules/path.lua'
ra.async   = ra.include_sh 'modules/async.lua'
ra.geom    = ra.include_sh 'modules/geometry.lua'
ra.ds      = ra.include_sh 'modules/datastructures.lua'
ra.net     = ra.include_sh 'modules/net.lua'
ra.kvo     = ra.include_sh 'modules/kvo.lua' -- depends on ra.fn
ra.surface = ra.include_cl 'modules/surface.lua'
ra.pon     = ra.include_sh 'modules/pon.lua'
ra.algorithm = ra.include_sh 'modules/algorithm.lua'

return ra
