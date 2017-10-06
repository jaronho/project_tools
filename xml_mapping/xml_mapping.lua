----------------------------------------------------------------------
-- 去除左右空格
local function stringDelLRS(str)
	assert("string" == type(str), "not support type "..type(str))
	return string.match(str,"%s*(.-)%s*$")
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
-- 写xml文件
local function writeXML(file, define)
	local function writeTitle()
		file:write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>")
		file:write("\n")
		file:write("<root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">")
		file:write("\n")
	end
	local function writeText()
		file:write("\t")
		file:write("<row>")
		file:write("\n")
		for _, value in pairs(define) do
			assert("string" == type(value), "not support value for type '"..type(value).."'")
			value = stringDelLRS(value)
			assert(string.len(value) > 0, "not support value for empty")
			file:write("\t")
			file:write("\t")
			file:write("<"..value..">".."</"..value..">")
			file:write("\n")
		end
		file:write("\t")
		file:write("</row>")
		file:write("\n")
	end
	local function writeEnd()
		file:write("</root>")
	end
	writeTitle()
	for i=1, 2 do
		writeText()
	end
	writeEnd()
end
----------------------------------------------------------------------
-- 入口函数
local function main(outputPath, xmlDefineFile)
	xpcall(function()
		assert("string" == type(outputPath), "outputPath not support for type '"..type(outputPath).."'")
		if string.len(outputPath) > 0 then
			outputPath = outputPath.."/"
		end
		assert("string" == type(xmlDefineFile), "xmlDefineFile not support for type '"..type(xmlDefineFile).."'")
		local fileInfo = stripFileInfo(xmlDefineFile)
		assert(".lua" == fileInfo.extname, "xmlDefineFile not support for extension '"..fileInfo.extname.."'")
		local xmlDefineTable = dofile(xmlDefineFile)
		if "table" ~= type(xmlDefineTable) then
			return
		end
		for fileName, xmlDefine in pairs(xmlDefineTable) do
			if "table" == type(xmlDefine) then
				local xmlFile = io.open(outputPath..stringDelLRS(fileName)..".xml", "w")
				if xmlFile then
					writeXML(xmlFile, xmlDefine)
					xmlFile:close()
				end
			end
		end
	end, function(msg)
		print(msg)
		os.execute("pause")
	end)
end
----------------------------------------------------------------------
return main