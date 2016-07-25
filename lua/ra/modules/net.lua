local work = {}
local read = {}

local MESSAGE_SIZE = 8 * 1024

local messageIndex = 1

local send = SERVER and net.Send or net.SendToServer 

if SERVER then
	util.AddNetworkString('net.bigdata.sendBlock')
	send = net.Send 
else 
	send = net.SendToServer 
end

function net.WriteBigData(data, players)
	local id = messageIndex
	local messageLength = string.len(data)

	net.WriteUInt(id, 32)
	net.WriteUInt(messageLength, 32)
	messageIndex = messageIndex + 1

	local segmentOffset = 1

	work[messageIndex] = function()
		local segment = string.sub(data, segmentOffset, segmentOffset + MESSAGE_SIZE)
		segmentOffset = segmentOffset + MESSAGE_SIZE + 1 

		local slen = string.len(segment)

		net.Start('net.bigdata.sendBlock')
		
		net.WriteUInt(id, 32)
		net.WriteUInt(slen, 16)
		net.WriteData(segment, slen)

		send(players)

		return segmentOffset > messageLength 
	end
end

function net.ReadBigData(callback, player)
	if SERVER then assert(player, "must pass the player to continue to read the data from") end
	
	local txnid = net.ReadUInt(32)
	local messageLength = net.ReadUInt(32)
	local tbl

	if SERVER then 
		tbl = read[player]
		if not tbh then tbl = {} read[player] = tbl end
	else 
		tbl = read 
	end

	tbl[txnid] = {
		txnid = txnid,
		messageParts = {},
		totalLength = 0,
		messageLength = messageLength,
		callback = callback,
	}
end

if SERVER then
	net.Receive('net.bigdata.sendBlock', function(_, pl)
		local txnid = net.ReadUInt(32)
		if not read[pl] or not read[pl][txnid] then return end 
		local segment = net.ReadData(net.ReadUInt(16))
		local obj = read[pl][txnid] 
		table.insert(obj.messageParts, segment)
		obj.totalLength = obj.totalLength + string.len(segment)

		if obj.totalLength >= messageLength then
			read[pl][txnid] = nil 
			obj.callback(table.concat(obj.messageParts))
		end
	end)
else
	net.Receive('net.bigdata.sendBlock', function()
		local txnid = net.ReadUInt(32)
		if not read[txnid] then return end
		local segment = net.ReadData(net.ReadUInt(16))

		local obj = read[txnid] 
		table.insert(obj.messageParts, segment)
		obj.totalLength = obj.totalLength + string.len(segment)

		if obj.totalLength >= obj.messageLength then
			read[txnid] = nil 
			obj.callback(table.concat(obj.messageParts, ''))
		end
	end)
end

if SERVER then 
	hook.Add('PlayerDisconnected', 'net.bigdata.cleanup', function(player)
		read[player] = nil 
	end)
end

timer.Create('net.bigdata.send', 0.05, 0, function()
	for k,v in pairs(work) do
		if v() then
			work[k] = nil 
		end
	end
end)
