@echo off
set path=%0
set path=%path:~1,-12%
set file=%1
set ip=127.0.0.1
set port=4096
set tag=1
set group=1
if defined file goto case2
:case1
set file=%path%\code.lua
call %path%\remote.exe -type client -ip %ip% -port %port% -tag %tag% -group %group% -flag %file% -content %file%
goto end
::处理lua文件
:case2
set file_type=%file:~-5,4%
if .lua NEQ %file_type% goto case3
call %path%\remote.exe -type client -ip %ip% -port %port% -tag %tag% -group %group% -flag %file% -content %file%
goto end
::处理图片文件
:case3
if .jpg NEQ %file_type% if .png NEQ %file_type% goto end
call %path%\remote.exe -type client -ip %ip% -port %port% -tag %tag% -group %group% -flag %file%
goto end
:end