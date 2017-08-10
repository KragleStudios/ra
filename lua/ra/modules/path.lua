local path = {}

path.getFolder = string.GetPathFromFilename
path.getFileName = string.GetFileFromFilename
path.getExtension = string.GetExtensionFromFilename
path.stripExtension = string.StripExtension
path.normalize = function(path)
	local stack = {}

	for k, seg in ipairs(string.Explode('/', path, false)) do
		if seg == '.' or seg == '' or seg == ' ' then
			continue
		elseif seg == '..'then
			stack[#stack] = nil
		else
			stack[#stack + 1] = seg
		end
	end

	return table.concat(stack, '/')
end

path.makeIntermediateDirectories = function(path)
	local start = 1
	while true do
		local next = string.find(path, '/', start, true)
		if not next then break end
		local partial = string.sub(path, 1, next)
		file.CreateDir(partial)
		start = next + 1
	end
	file.CreateDir(path)
end

return path
