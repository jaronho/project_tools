﻿autoincrement.exe 是一个用于把指定文件内的数值进行自动累加的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-file 填写完整文件名(如:绝对路径D:/temp/111.txt或相对路径temp/111.txt)

例子: autoincrement.exe -file temp/111.txt

执行程序后,将会覆盖原文件
PS：文件内容必须为数字字符串(只能包含数字字符),如：1 或者 0000202
