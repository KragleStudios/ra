local path = {}

path.getFolder = string.GetPathFromFilename
path.getFileName = string.GetFileFromFilename
path.getExtension = string.GetExtensionFromFilename
path.stripExtension = string.StripExtension
path.normalize = function(path)
	local stack = {}
	local last = 0
	while true do 
		local next = string.find(path, '/', last + 1, true)
		if not next then break end 
		local str = string.sub(last + 1, next - 1)
		if str == '..' then
			stack[#stack] = nil
		elseif str ~= '.' then
			stack[#stack + 1] = str
		end
		last = next
	end
	return table.concat(stack, '/')
end


return path