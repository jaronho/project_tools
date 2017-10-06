@echo off
set output_path=output
set xml_define_file=XMLDEFINE.lua
::创建输出文件夹
rd /s/q %output_path%
md %output_path%
::xml文件生成
call ..\lua\lua.exe -e "local main=dofile('xml_mapping.lua') main('%output_path%', '%xml_define_file%')"