merge.exe 是一个用于把指定文件内容合并起来的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-file 填写完整文件名(如:绝对路径D:/temp/111.txt或相对路径temp/111.txt)
(2)选项-newline 带有改标识表示每个文件内容要换行
(2)选项-list 填写要合并的文件名列表

例子: merge.exe -file temp/a.txt -newline -list 1.txt 2.txt 3.txt
