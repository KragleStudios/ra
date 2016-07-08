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


return path