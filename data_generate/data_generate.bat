@echo off
set source_path=data
REM set file_name=tplt_map
set target_path=output
rd /s/q %target_path%
md %target_path%
::数据生成
call ..\data2lua.exe -dir %source_path% -ext .xml
call ..\lua\lua.exe -e "local main=dofile('data_generate.lua') main('%source_path%', '%file_name%')"
::单个lua文件
if "" == "%file_name%" goto case1
copy %source_path%\%file_name%.lua %target_path%
goto end
::多个lua文件
:case1
xcopy /e/y %source_path%\*.lua %target_path%
goto end
:end
del %source_path%\*.lua
del %source_path%\*.js
del %source_path%\*.php