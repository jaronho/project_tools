----------------------------------------------------------------------
-- 去除左右空格
local function stringDelLRS(str)
	assert("string" == type(str), "not support type "..type(str))
	return string.match(str,"%s*(.-)%s*$")
end
----------------------------------------------------------------------
-- 字符串分割
local function stringSplit(fileStr, delimiter, numberType)
    if "string" ~= type(fileStr) or '' == fileStr or "" == fileStr or "string" ~= type(delimiter) or '' == delimiter or "" == delimiter then
		if numberType then
			return {tonumber(fileStr)}
		else
			return {fileStr}
		end
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
		local pos = string.find(fileStr, delimiter)
		if (not pos) then
			if numberType then
				arr[#arr + 1] = tonumber(fileStr)
			else
				arr[#arr + 1] = fileStr
			end
			break
		end
		local value = string.sub(fileStr, 1, pos - 1)
		if numberType then
			arr[#arr + 1] = tonumber(value)
		else
			arr[#arr + 1] = value
		end
		fileStr = string.sub(fileStr, pos + 1, #fileStr)
	end
	return arr
end
----------------------------------------------------------------------
-- 解析元组
local function parseTuple(stringTuple, delimiter, numberType)
	local function removeLRBracket(fileStr)
		local leftB, rightB, pos, count = 0, 0, 1, 0
		while pos <= string.len(fileStr) do
			local ch = string.sub(fileStr, pos, pos)
			if "{" == ch then
				count = count + 1
				if 0 == leftB then
					leftB = pos
				end
			elseif "}" == ch then
				count = count - 1
			end
			if 0 == count then
				rightB = pos
				break
			end
			pos = pos + 1
		end
		if 1 == leftB and string.len(fileStr) == rightB then
			return string.sub(fileStr, leftB + 1, rightB - 1), true
		end
		return fileStr, false
	end
	local function innerParse(fileStr, tuple, index)
		index = index or 1
		local tempStr, removeFlag = removeLRBracket(fileStr)
		local tempTuple = nil
		if removeFlag then
			tuple[index] = {}
			tempTuple = tuple[index]
		else
			tempTuple = tuple
		end
		if nil == string.find(tempStr, delimiter) then
			if removeFlag then
				if numberType then
					table.insert(tempTuple, tonumber(tempStr))
				else
					table.insert(tempTuple, tempStr)
				end
			else
				if numberType then
					tempTuple[index] = tonumber(tempStr)
				else
					tempTuple[index] = tempStr
				end
			end
		else
			local blockTable, blockStr, startPos, left, right = {}, "", 1, 0, 0
			while startPos <= string.len(tempStr) do
				local character = string.sub(tempStr, startPos, startPos)
				startPos = startPos + 1
				if delimiter == character and left == right then
					table.insert(blockTable, blockStr)
					character, blockStr, left, right = "", "", 0, 0
				elseif "{" == character then
					left = left + 1
				elseif "}" == character then
					right = right + 1
				end
				blockStr = blockStr..character
			end
			assert(left == right, stringTuple.." format is error")
			table.insert(blockTable, blockStr)
			for key, value in pairs(blockTable) do
				innerParse(value, tempTuple, key)
			end
		end
	end
	local tupleTable = {}
	innerParse(stringTuple, tupleTable)
	return tupleTable
end
----------------------------------------------------------------------
-- 解析文件信息
local function stripFileInfo(fullFileName)
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
-- 转换列表
local function toList(str, numberType)
	if string.find(str, ",") then
		return stringSplit(str, ",", numberType)
	end
	return stringSplit(str, "|", numberType)
end
----------------------------------------------------------------------
-- 转换元组
local function toTuple(str, numberType)
	if string.find(str, ",") then
		return parseTuple(str, ",", numberType)
	end
	return parseTuple(str, "|", numberType)
end
----------------------------------------------------------------------
-- 索引标识
local function signIndex(index, langType)
	if "lua" == langType then
		if nil == tonumber(index) then
			return "[\""..index.."\"]"
		else
			return "["..index.."]"
		end
	elseif "js" == langType then
		return index
	elseif "php" == langType then
		if nil == tonumber(index) then
			return "\""..index.."\""
		else
			return index
		end
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 键值标识
local function signKey(key, langType)
	if "lua" == langType then
		if nil == tonumber(key) then
			return key
		else
			return "["..key.."]"
		end
	elseif "js" == langType then
		return key
	elseif "php" == langType then
		if nil == tonumber(key) then
			return "\""..key.."\""
		else
			return key
		end
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 等号标识
local function signEqual(langType)
	if "lua" == langType then
		return "="
	elseif "js" == langType then
		return ":"
	elseif "php" == langType then
		return "=>"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 列表起始标识
local function signListStart(langType)
	if "lua" == langType then
		return "{"
	elseif "js" == langType then
		return "["
	elseif "php" == langType then
		return "["
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 列表结束标识
local function signListEnd(langType)
	if "lua" == langType then
		return "}"
	elseif "js" == langType then
		return "]"
	elseif "php" == langType then
		return "]"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 对象起始标识
local function signObjectStart(langType)
	if "lua" == langType then
		return "{"
	elseif "js" == langType then
		return "{"
	elseif "php" == langType then
		return "["
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 对象结束标识
local function signObjectEnd(langType)
	if "lua" == langType then
		return "}"
	elseif "js" == langType then
		return "}"
	elseif "php" == langType then
		return "]"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 语句结束标识
local function signStatementEnd(langType)
	if "lua" == langType then
		return ""
	elseif "js" == langType then
		return ";"
	elseif "php" == langType then
		return ";"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 文件头
local function fileHead(langType)
	if "lua" == langType then
		return ""
	elseif "js" == langType then
		return ""
	elseif "php" == langType then
		return "<?php\n"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 文件扩展标识
local function signFileExt(langType)
	if "lua" == langType then
		return ".lua"
	elseif "js" == langType then
		return ".js"
	elseif "php" == langType then
		return ".php"
	end
	assert(nil, "unable to handle language type ["..tostring(langType).."]")
end
----------------------------------------------------------------------
-- 序列化数据
local function serialize(data, langType)
	local serializeStr = ""
	local function innerSerialize(value, keyFlag)
		local valueType = type(value)
		if "nil" == valueType or "boolean" == valueType then
			serializeStr = serializeStr..tostring(value)
		elseif "number" == valueType then
			if not keyFlag then
				serializeStr = serializeStr..value
			end
		elseif "string" == valueType then
			if keyFlag then
				serializeStr = serializeStr..value..signEqual(langType)
			else
				serializeStr = serializeStr..string.format("%q", value)
			end
		elseif "table" == valueType then
			serializeStr = serializeStr..signListStart(langType)
			local index = 0
			for k, v in pairs(value) do
				index = index + 1
				serializeStr = serializeStr..(index > 1 and "," or "")
				innerSerialize(k, true)
				innerSerialize(v, false)
			end
			serializeStr = serializeStr..signListEnd(langType)
		else
			assert(nil, "cannot support type: "..valueType..", value: "..tostring(value))
		end
	end
	innerSerialize(data, false)
	return serializeStr
end
----------------------------------------------------------------------
-- 写文件
local function writeFile(fileName, fileStr)
	local file = assert(io.open(fileName, "wb"), "open or create file '"..fileName.."' error ...")
	if nil == file then
		return
	end
	file:write(fileStr)
	file:close()
end
----------------------------------------------------------------------
-- 分割字段类型和名称
local function splitTypeAndName(field)
	local sp, ep = string.find(field, ":")
	if nil == sp or 1 == sp or nil == ep or string.len(field) == ep then
		sp, ep = string.find(field, "%.")
		if nil == sp or 1 == sp or nil == ep or string.len(field) == ep then
			return nil
		end
	end
	local typeStr = string.sub(field, 1, sp - 1)
	assert(string.len(typeStr) > 0, "type must be not empty")
	local nameStr = string.sub(field, ep + 1, string.len(field))
	assert(string.len(nameStr) > 0, "name must be not empty")
	-- 名称只能为(数字,字母,下划线组成)
	for i=1, string.len(nameStr) do
		local b = string.byte(string.sub(nameStr, i, i))
		if not ((b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or 95 == b) then
			assert(nil, "unable to handle name ["..tostring(nameStr).."], name only by number, letter and underscore")
		end
	end
	return typeStr, nameStr
end
----------------------------------------------------------------------
-- 解析顺序表
local function parseOrder(fullFileName, dataTable, langType)
	assert("table" == type(dataTable), "file "..fullFileName.." is not table format")
	local fieldTable = dataTable[1]
	assert("table" == type(fieldTable), "file "..fullFileName.." field is error")
	local fieldCount, keyTable, row, dataStr = #fieldTable, {}, 0, signObjectStart(langType)
	for index=2, #dataTable do
		local valueTable = dataTable[index]
		if fieldCount == #valueTable then
			row = row + 1
			local key, rowStr = nil, signObjectStart(langType)
			for i=1, fieldCount do
				local field, value = stringDelLRS(fieldTable[i]), stringDelLRS(valueTable[i])
				local fieldType, fieldName = splitTypeAndName(field)
				if i > 1 then
					rowStr = rowStr..","
				end
				rowStr = rowStr..signKey(fieldName, langType)..signEqual(langType)
				if "key_number" == fieldType then
					assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
					key = tonumber(value)
					assert(key, "file "..fullFileName.." value '"..tostring(value).."'is error at index "..index)
					rowStr = rowStr..key
				elseif "key_string" == fieldType then
					assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
					key = tostring(value)
					rowStr = rowStr.."\""..key.."\""
				elseif "number" == fieldType then
					assert(tonumber(value), "file "..fullFileName.." value '"..tostring(value).."'is error at index "..index)
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr.."0"
					else
						rowStr = rowStr..tonumber(value)
					end
				elseif "string" == fieldType then
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr.."\"\""
					else
						rowStr = rowStr.."\""..tostring(value).."\""
					end
				elseif "list_number" == fieldType then
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr..signListStart(langType)..signListEnd(langType)
					else
						rowStr = rowStr..serialize(toList(value, true), langType)
					end
				elseif "list_string" == fieldType then
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr..signListStart(langType)..signListEnd(langType)
					else
						rowStr = rowStr..serialize(toList(value, false), langType)
					end
				elseif "tuple_number" == fieldType then
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr..signListStart(langType)..signListEnd(langType)
					else
						rowStr = rowStr..serialize(toTuple(value, true), langType)
					end
				elseif "tuple_string" == fieldType then
					if "" == value or "nil" == value or "null" == value then
						rowStr = rowStr..signListStart(langType)..signListEnd(langType)
					else
						rowStr = rowStr..serialize(toTuple(value, false), langType)
					end
				else
					assert(false, "file "..fullFileName.." field name \""..tostring(fieldName).."\" is error format")
				end
			end
			rowStr = rowStr..signObjectEnd(langType)
			if nil == key then
				key = row
			end
			assert(not keyTable[key], "file "..fullFileName.." key "..key.." is duplicate at index "..index)
			keyTable[key] = true
			if row > 1 then
				dataStr = dataStr..","
			end
			dataStr = dataStr.."\n"..signIndex(key, langType)..signEqual(langType)..rowStr
		else
			print("Warning: file "..fullFileName.." value is error at index "..index)
		end
	end
	dataStr = dataStr.."\n"..signObjectEnd(langType)
	return dataStr
end
----------------------------------------------------------------------
-- 解析哈希表
local function parseHash(fullFileName, dataTable, langType)
	assert("table" == type(dataTable), "file "..fullFileName.." is not table format")
	local row, keyTable, dataStr = 0, {}, signObjectStart(langType)
	for index=1, #dataTable do
		local valueTable = dataTable[index]
		row = row + 1
		local col, key, rowStr = 0, nil, "{"
		for field, value in pairs(valueTable) do
			field = stringDelLRS(field)
			value = stringDelLRS(value)
			local fieldType, fieldName = splitTypeAndName(field)
			col = col + 1
			if col > 1 then
				rowStr = rowStr..","
			end
			rowStr = rowStr..signKey(fieldName, langType)..signEqual(langType)
			if "key_number" == fieldType then
				assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
				key = tonumber(value)
				assert(key, "file "..fullFileName.." value '"..tostring(value).."'is error at index "..index)
				rowStr = rowStr..key
			elseif "key_string" == fieldType then
				assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
				key = tostring(value)
				rowStr = rowStr.."\""..key.."\""
			elseif "number" == fieldType then
				assert(tonumber(value), "file "..fullFileName.." value '"..tostring(value).."'is error at index "..index)
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr.."0"
				else
					rowStr = rowStr..tonumber(value)
				end
			elseif "string" == fieldType then
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr.."\"\""
				else
					rowStr = rowStr.."\""..tostring(value).."\""
				end
			elseif "list_number" == fieldType then
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr..signListStart(langType)..signListEnd(langType)
				else
					rowStr = rowStr..serialize(toList(value, true), langType)
				end
			elseif "list_string" == fieldType then
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr..signListStart(langType)..signListEnd(langType)
				else
					rowStr = rowStr..serialize(toList(value, false), langType)
				end
			elseif "tuple_number" == fieldType then
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr..signListStart(langType)..signListEnd(langType)
				else
					rowStr = rowStr..serialize(toTuple(value, true), langType)
				end
			elseif "tuple_string" == fieldType then
				if "" == value or "nil" == value or "null" == value then
					rowStr = rowStr..signListStart(langType)..signListEnd(langType)
				else
					rowStr = rowStr..serialize(toTuple(value, false), langType)
				end
			else
				assert(false, "file "..fullFileName.." field name \""..tostring(fieldName).."\" is error format")
			end
		end
		rowStr = rowStr..signObjectEnd(langType)
		if nil == key then
			key = row
		end
		assert(not keyTable[key], "file "..fullFileName.." key "..key.." is duplicate at index "..index)
		keyTable[key] = true
		if row > 1 then
			dataStr = dataStr..","
		end
		dataStr = dataStr.."\n"..signIndex(key, langType)..signEqual(langType)..rowStr
	end
	dataStr = dataStr.."\n"..signObjectEnd(langType)
	return dataStr
end
----------------------------------------------------------------------
-- 遍历指定路径下的文件
local function traverseFile(path)
	local fileNameTable = {}
	for fullFileName in io.popen("dir "..path.." /b/s"):lines() do
		table.insert(fileNameTable, fullFileName)
	end
	return fileNameTable
end
----------------------------------------------------------------------
-- 解析数据字符串
local function parseDataString(fullFileName, dataTable, langType)
	if "table" ~= type(dataTable) or "table" ~= type(dataTable[1]) then
		return
	end
	local dataStr = nil
	if "string" == type(dataTable[1][1]) then
		dataStr = parseOrder(fullFileName, dataTable, langType)
	else
		dataStr = parseHash(fullFileName, dataTable, langType)
	end
	return dataStr
end
----------------------------------------------------------------------
-- 入口函数
local function main(path, fileName)
	xpcall(function()
		assert("string" == type(path) and string.len(path) > 0, "path must be string and exist")
		local fileTb = traverseFile(path.."\\*.lua")
		local langList = {
			["lua"] = {head="", buffer=nil},
			["js"] = {head="", buffer=nil},
			["php"] = {head="<?php\n", buffer=nil},
		}
		for _, fullFileName in pairs(fileTb) do
			local dataTable = dofile(fullFileName)
			for langType, lang in pairs(langList) do
				local dataStr = parseDataString(fullFileName, dataTable, langType)
				if dataStr then
					local fileInfo = stripFileInfo(fullFileName)
					if "string" == type(fileName) and string.len(fileName) > 0 then
						if "string" == type(lang.buffer) and string.len(lang.buffer) > 0 then
							lang.buffer = lang.buffer..",\n"
						end
						lang.buffer = (lang.buffer or "")..signKey(stringDelLRS(fileInfo.basename), langType)..signEqual(langType)..dataStr
					else
						writeFile(path.."/"..stringDelLRS(fileInfo.basename)..signFileExt(langType), lang.head.."return"..dataStr..signStatementEnd(langType))
					end
				end
			end
		end
		if "string" == type(fileName) and string.len(fileName) > 0 then
			for langType, lang in pairs(langList) do
				local fileString = stringDelLRS(fileName).."="..signObjectStart(langType).."\n"
				fileString = fileString..lang.buffer
				fileString = fileString.."\n"..signObjectEnd(langType)..signStatementEnd(langType)
				writeFile(path.."/"..stringDelLRS(fileName)..signFileExt(langType), lang.head..fileString)
			end
		end
	end, function(msg)
		print(msg)
		os.execute("pause")
	end)
end
----------------------------------------------------------------------
return main