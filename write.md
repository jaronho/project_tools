﻿write.exe 是一个用于写文件的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-pre 添加在旧的文件内容前面
(2)选项-rep 替代旧的文件内容
(3)选项-suf 添加在旧的文件内容后面
(4)选项-file 填写目录路径(如:绝对路径D:/temp/111.txt或相对路径temp/111.txt)
(5)选项-str 要写入文件的内容 

例子: write.exe -rep -dir file/111.txt -str \r\n1.00.004

