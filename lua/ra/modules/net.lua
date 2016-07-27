local net = net 
local ranet = {}

if SERVER then 
	util.AddNetworkString('ra.pns')
end

local txnid = 0
function ranet.WriteStream(data, targs, callback)
	-- generate a unique id for this txn
	txnid = (txnid + 1) % 0xFFFF

	-- iterate over the data to send
	local count = 0
	local iter = function()
		local seg = data:sub(count, count + 0x7FFF)
		count = count + 0x8000

		return seg
	end

	-- send a chunk of data
	local function send()
		local block = iter()
		local size = block:len()
		if block and block:len() > 0 then
			net.Start('ra.pns')
				net.WriteUInt(txnid, 16)
				net.WriteUInt(size, 16)
				net.WriteData(block, size)
			if SERVER then
			net.Send(targs)
			else
			net.SendToServer()
			end
			timer.Simple(0.01, send)
		elseif callback then
			callback()
		end
	end

	-- write txnid and chunks to be expected
	net.WriteUInt(txnid, 16)
	net.WriteUInt(math.ceil(data:len()/ 0x8000), 16)
	
	timer.Simple(0.01, send)
end

local buckets = {}
if SERVER then
	function ranet.ReadStream(src, callback)
		if not src then error('stream source must be provided to receive a stream from a player') end
		if not callback then error('callback must be provided for stream read completion') end
		if not buckets[src] then buckets[src] = {} end
		buckets[src][net.ReadUInt(16)] = {len=net.ReadUInt(16), callback=callback}
	end
	net.Receive('ra.pns', function(_,pl)
		local txnid = net.ReadUInt(16)
		if not buckets[pl] or not buckets[pl][txnid] then return end

		local bucket = buckets[pl][txnid]

		local size = net.ReadUInt(16)
		local data = net.ReadData(size)
		bucket[#bucket+1] = data

		if #bucket == bucket.len then
			buckets[pl][txnid] = nil
			bucket.callback(table.concat(bucket))
		end
	end)
else
	
	function ranet.ReadStream(callback)
		if not callback then
			error('callback must be provided for stream read completion')
		end
		buckets[net.ReadUInt(16)] = {len=net.ReadUInt(16), callback=callback}
	end

	net.Receive('ra.pns', function(_)
		local txnid = net.ReadUInt(16)
		if not buckets[txnid] then return end

		local bucket = buckets[txnid]

		local size = net.ReadUInt(16)
		local data = net.ReadData(size)
		bucket[#bucket+1] = data

		if #bucket == bucket.len then
			buckets[txnid] = nil
			bucket.callback(table.concat(bucket))
		end
	end)
end


if CLIENT then 
	local queue = {}
	local function processQueue()
		if queue then 
			for k,v in ipairs(queue) do
				v()
			end
			queue = nil 
		end
	end

	hook.Add('InitPostEntity', 'net.waitForPlayer', function()
		processQueue()
	end)

	function ranet.WaitForPlayer(fn)
		if queue and IsValid(LocalPlayer()) then
			processQueue()
		end
		if not queue then
			fn()
		else
			table.insert(queue, fn)
		end
	end
end

return ranet 