----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-09-25
-- Brief: remote client for lua
----------------------------------------------------------------------
local RemoteClient = {}
----------------------------------------------------------------------
function RemoteClient:stringSplit(str, delimiter, numberType)
    if "string" ~= type(str) or '' == str or "" == str or "string" ~= type(delimiter) or '' == delimiter or "" == delimiter then
		return {str}
	end
	local speCharTable = {"(", ")", ".", "%", "+", "-", "*", "?", "[", "^", "$"}
	for key, speChar in pairs(speCharTable) do
		if delimiter == speChar then
			delimiter = "%"..delimiter
			break
		end
	end
	local arr = {}
	while true do
		local pos = string.find(str, delimiter)
		if (not pos) then
			if true == numberType then
				arr[#arr + 1] = tonumber(str)
			else
				arr[#arr + 1] = str
			end
			break
		end
		local value = string.sub(str, 1, pos - 1)
		if true == numberType then
			arr[#arr + 1] = tonumber(value)
		else
			arr[#arr + 1] = value
		end
		str = string.sub(str, pos + 1, #str)
	end
	return arr
end
----------------------------------------------------------------------
function RemoteClient:stripFileInfo(fullFileName)
	assert("string" == type(fullFileName), "not support type "..type(fullFileName))
	local pos = string.len(fullFileName)
	local extpos = pos + 1
	while pos > 0 do
		local b = string.byte(fullFileName, pos)
		if 46 == b then		-- "."
			extpos = pos
		elseif 47 == b or 92 == b then	-- "/","\\"
			break
		end
		pos = pos - 1
	end
	local dirname = string.sub(fullFileName, 1, pos)
	local filename = string.sub(fullFileName, pos + 1)
	extpos = extpos - pos
	local basename = string.sub(filename, 1, extpos - 1)
	local extname = string.sub(filename, extpos)
	return {dirname = dirname, filename = filename, basename = basename, extname = extname}
end
----------------------------------------------------------------------
function RemoteClient:bytesToNumber(bytes, endian, signed)
	local t = {string.byte(bytes, 1, -1)}
	-- reverse bytes
	if "big" == endian then
		local tt = {}
		for k=1, #t do
			tt[#t - k + 1] = t[k]
		end
		t = tt
	end
	local num = 0
	for k=1, #t do
		num = num + t[k]*2^((k - 1)*8)
	end
	if signed then
		-- if last bit set, negative
		num = (num > 2^(#t - 1) - 1) and (num - 2^#t) or num
	end
	return num
end
----------------------------------------------------------------------
function RemoteClient:parseNetInfo(buffer)
	local info = {ip = "", port = 0, group = "", flag = "", content = ""}
	-- ip
	local ipHeadPos, ipHeadLen = 1, 4
	local ipHead = string.sub(buffer, ipHeadPos, ipHeadLen)
	local ipPos, ipLen = ipHeadPos + ipHeadLen, self:bytesToNumber(ipHead)
	if ipLen > 0 then
		info.ip = string.sub(buffer, ipPos, ipPos + ipLen - 1)
	end
	-- port
	local portPos, portLen = ipPos + ipLen, 4
	info.port = self:bytesToNumber(string.sub(buffer, portPos, portPos + portLen - 1))
	-- group
	local groupHeadPos, groupHeadLen = portPos + portLen, 4
	local groupHead = string.sub(buffer, groupHeadPos, groupHeadPos + groupHeadLen - 1)
	local groupPos, groupLen = groupHeadPos + groupHeadLen, self:bytesToNumber(groupHead)
	if groupLen > 0 then
		info.group = string.sub(buffer, groupPos, groupPos + groupLen - 1)
	end
	-- flag
	local flagHeadPos, flagHeadLen = groupPos + groupLen, 4
	local flagHead = string.sub(buffer, flagHeadPos, flagHeadPos + flagHeadLen - 1)
	local flagPos, flagLen = flagHeadPos + flagHeadLen, self:bytesToNumber(flagHead)
	if flagLen > 0 then
		info.flag = string.sub(buffer, flagPos, flagPos + flagLen - 1)
	end
	-- content
	local contentHeadPos, contentHeadLen = flagPos + flagLen, 4
	local contentHead = string.sub(buffer, contentHeadPos, contentHeadPos + contentHeadLen - 1)
	local contentPos, contentLen = contentHeadPos + contentHeadLen, self:bytesToNumber(contentHead)
	if contentLen > 0 then
		info.content = string.sub(buffer, contentPos, contentPos + contentLen - 1)
	end
	return info
end
----------------------------------------------------------------------
function RemoteClient:create(ip, port, group, heartbeat, callFunc, target)
	if "string" ~= type(ip) or string.len(ip) < 7 then
		print("remote ip:", ip, "is error")
		return
	end
	if "number" ~= type(port) or port < 0 then
		print("remote port:", port, "is error")
		return
	end
	if "string" ~= type(group) or 0 == string.len(group) then
		print("remote group:", group, "is error")
		return
	end
	if "number" ~= type(heartbeat) or heartbeat < 0 then
		print("remote heartbeat:", heartbeat, "is error")
		return
	end
	local obj = {
		mSocket = nil,
		mIP = ip,
		mPort = math.ceil(port),
		mGroup = group,
		mHeartbeat = heartbeat,
		mReceiveBuffer = "",
		mHeartbeatTime = 0,
		mCallFunc = callFunc,
		mTarget = target
 	}
	setmetatable(obj, {__index = RemoteClient})
	return obj
end
----------------------------------------------------------------------
function RemoteClient:destroy(errorCode)
	if self.mSocket then
		self.mSocket:close()
	end
	self.mSocket = nil
	self.mIP = nil
	self.mPort = nil
	self.mGroup = nil
	self.mHeartbeat = 0
	self.mReceiveBuffer = ""
	self.mHeartbeatTime = 0
	-- errorCode: 1.server is not open,2.server is busy,3.server is closed
	if errorCode > 0 and "function" == type(self.mCallFunc) then
		if "table" == type(self.mTarget) or "userdata" == type(self.mTarget) then
			self.mCallFunc(self.mTarget, errorCode)
		else
			self.mCallFunc(errorCode)
		end
	end
	self.mCallFunc = nil
	self.mTarget = nil
end
----------------------------------------------------------------------
function RemoteClient:update()
	if not self.mSocket and self.mIP and self.mPort and self.mGroup then
		self.mSocket = require("socket").connect(self.mIP, self.mPort)
		if self.mSocket then
			self.mSocket:settimeout(0)
			self.mHeartbeatTime = os.clock()
		else
			print("remote connect ip: "..self.mIP.." port: "..self.mPort.." group: "..self.mGroup.." fail")
			self:destroy(1)
		end
	end
	if not self.mSocket then
		return
	end
	local content, status, received = self.mSocket:receive(1024 * 16)
	local data = nil
	if content and string.len(content) > 0 then
		data = content
	elseif received and string.len(received) > 0 then
		data = received
	else
		if "closed" == status or(self.mHeartbeat > 0 and os.clock() - self.mHeartbeatTime > self.mHeartbeat + 5) then
			print("remote server ip: "..self.mIP.." port: "..self.mPort.." is closed")
			self:destroy(3)
		end
		return
	end
	self.mReceiveBuffer = self.mReceiveBuffer..data
	local recvBuf = self.mReceiveBuffer
	if string.len(recvBuf) < 4 then
		return
	end
	local packSize = string.swab32_array(recvBuf)
	recvBuf = string.sub(recvBuf, 4 + 1)
	if string.len(recvBuf) < packSize then
		return
	end
	self.mReceiveBuffer = string.sub(recvBuf, packSize + 1)
    local body = string.sub(recvBuf, 1, packSize)
	local info = self:parseNetInfo(body)
	if "SERVER_STATUS_BUSY" == info.content then
		print("remote connect ip: "..self.mIP.." port: "..self.mPort.." group: "..self.mGroup.." fail, server busy")
		self:destroy(2)
		return
	elseif "SERVER_STATUS_FREE" == info.content then
		print("remote connect ip: "..self.mIP.." port: "..self.mPort.." group: "..self.mGroup.." success")
		return
	elseif "SERVER_HEARTBEAT" == info.content then
		self.mHeartbeatTime = os.clock()
		return
	end
	xpcall(function()
		local fullFileName, content = info.flag, info.content
		local file, errorMsg = io.open(content, "rb")
		if file then	-- check if content is file name
			local tmpFullFileName = content
			content = file:read("*all")
			file:close()
			if not content then
				print("reload fail, can't open file "..tmpFullFileName..", error: "..errorMsg)
				return
			end
		end
		print("reload "..fullFileName)
		local fileInfo = self:stripFileInfo(fullFileName)
		self:handleLogic(fullFileName, fileInfo.filename, fileInfo.basename, fileInfo.extname, content)
	end, function(msg)
		local errorMsgStart		= "--------------------------- reload error --------------------------\n"
		local errorMsgContent	= "LUA ERROR:\n"..tostring(msg).."\n"
		local errorMsgTraceback	= debug.traceback().."\n"
		local errorMsgEnd		= "-------------------------------------------------------------------\n"
		print(errorMsgStart..errorMsgContent..errorMsgTraceback..errorMsgEnd)
	end)
end
----------------------------------------------------------------------
function RemoteClient:handleLogic(fullFileName, fileName, fileBaseName, fileExtName, content)
	-- 以下代码逻辑根据不同的项目具体而定
	if ".lua" == fileExtName then
		-- 截取文件名的末5位
		local operationType = string.sub(fullFileName, -9, -5)
		if not operationType or "" == operationType then
			print("reload fail, can't parse operation type ["..tostring(operationType).."]")
			return
		end
		if "_tplt" == operationType then	-- 数据表
			_G[fileBaseName]:reload()
			print("reload tplt success")
		else	-- 代码文件
			if "" == cc.FileUtils:getInstance():fullPathForFilename(fileName) then
				assert(loadstring(content), content)()
				print("reload code success")
			else
				package.loaded[fileBaseName] = nil
				assert(require(fileBaseName), fullFileName)
				print("reload lua success")
			end
		end
	elseif ".jpg" == fileExtName or ".png" == fileExtName then
		if cc.Director:getInstance():getTextureCache():reloadTexture(fileName) then
			print("reload picture success")
		else
			print("reload picture error")
		end
	else
		print("reload fail, can't parse file type ["..fileExtName.."]")
	end
end
----------------------------------------------------------------------
------------------------[[ public interface ]]------------------------
----------------------------------------------------------------------
local mServerIP, mServerPort, mGroup, mHeartbeat = "127.0.0.1", 4096, "2", 0
----------------------------------------------------------------------
function RemoteClientUpdate(callFunc, target)
	if not g_RemoteClient then
		g_RemoteClient = RemoteClient:create(mServerIP, mServerPort, mGroup, mHeartbeat, callFunc, target)
	end
	if g_RemoteClient then
		g_RemoteClient:update()
	end
end
----------------------------------------------------------------------
function RemoteClientChange(ip, port, group, heartbeat)
	if g_RemoteClient then
		g_RemoteClient:destroy(0)
	end
	g_RemoteClient = nil
	if "string" == type(ip) and string.len(ip) >= 7 then
		mServerIP = ip
	end
	if "number" == type(port) and port > 0 then
		mServerPort = math.ceil(port)
	end
	if "string" == type(group) and string.len(group) > 0 then
		mGroup = group
	end
	if "number" == type(heartbeat) and heartbeat > 0 then
		mHeartbeat = heartbeat
	end
end
----------------------------------------------------------------------