﻿md5.exe 是一个用于把当前目录下所有文件生成md5值的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-dir 填写目录路径(如:绝对路径D:/temp或相对路径temp)
(2)选项-cut 文件列表中,对应的md5值的名称默认是文件的绝对路径,此参数标识把路径从该处截断
(3)选项-ext 要查询的文件类型

例子: md5.exe -dir temp -cut temp -ext .lua .xml .jpg

执行程序后,当目录路径创建一个Md5ListFile.txt的文件
