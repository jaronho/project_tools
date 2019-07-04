traverse.exe 是一个用于搜索指定目录下子目录或文件的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-type 搜索类型(1.目录,2.文件)
(2)选项-recursion 是否递归搜索(0.不递归,1.递归)
(3)选项-dir 填写目录路径(如:绝对路径D:/temp或相对路径temp)
(4)选项-cut 文件列表中,对应的md5值的名称默认是文件的绝对路径,此参数标识把路径从该处截断
(5)选项-ext 要查询的文件类型,当2 == type时有效(如:.lua .xml)

例子: traverse.exe -type 2 -recursion 1 -dir temp -cut temp -ext .lua .xml .jpg

执行程序后,当目录路径创建一个TraverseList.txt的文件
