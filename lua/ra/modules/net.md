# ra.net

# REALM: SERVER
```Lua
ra.net.WaitForPlayer(player, callback)
ra.net.WriteBigData('binary data', playersToSendTo) -- a function for sending very large blocks of data, players must be same as in net.Send or it will cause bad errors
ra.net.ReadBigData(function(data) --[[callback]] end, fromPlayer) -- reads a data stream from the player specified
```

# REALM: CLIENT
```Lua
ra.net.WaitForPlayer(player, callback)
ra.net.WriteBigData('binary data') -- a function for sending very large blocks of data
ra.net.ReadBigData(function(data) --[[callback]] end) -- reads a data stream from the server
```
