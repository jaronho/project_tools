﻿crypto.exe 是一个用于把当前目录下所有文件进行加密/解密的小程序

用法: 通过cmd或其他方式运行该exe,后面传入一定的参数

参数规则: 
(1)选项-alg		算法,1-XOR,2-AES,3-RC4,4-xxtea
(2)选项-op		操作类型,1-加密,2-解密
(3)选项-key		秘钥
(4)选项-sign	签名
(5)选项-dir		目录路径(如:绝对路径D:/temp或相对路径temp)
(6)选项-ext		文件类型

例子: crypto.exe -alg 1 -op 1 -key abc123 -sign hahah -dir D:/temp -ext .lua .xml .jpg

执行程序后,将会覆盖原文件
