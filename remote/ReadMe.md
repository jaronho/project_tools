######################################################################
remote.exe
参数规则: 
(1)选项-type		类型:client,server
(2)选项-ip			地址,如:127.0.0.1
(3)选项-port		端口,如:4096
(4)选项-tag			标签:0.隐藏内容,1.显示内容
(5)选项-group		客户端组别,当type为client时有效,如:0(可发送/接收所有组别),1(可发送所有组别),2(可接收所有组别),...(其他,只能和相同的组别通信)
(6)选项-flag		客户端内容标志,当type为client时有效,表示content的自定义标志,如:code,tplt,...
(7)选项-content		客户端发送内容,当type为client时有效,文件路径(则发送文件内容,若文件内容过大,则发送文件路径)或字符串内容(直接发送),如:F:\temp.txt,hello
(8)选项-count		服务端连接数,当type为server时有效,指定可连接服务端的客户端数量,>=2
(9)选项-heartbeat	服务端心跳间隔,当type为server时有效(默认没有心跳)
例子:
remote.exe -type server -ip 127.0.0.1 -port 4096 -tag 1 -count 3 -heartbeat 30
remote.exe -type client -ip 127.0.0.1 -port 4096 -tag 1 -group abc -flag code -content hello,world
remote.exe -type client -ip 127.0.0.1 -port 4096 -tag 1 -group abc -flag code -content F:\temp.txt
######################################################################
server.bat:
	中转服务器,双击运行即可,可通过编辑来修改参数

client.bat:
	发送客户端,一般通过编辑器来调用,可通过编辑来修改参数
	如果双击也可以运行,则发送的内容为code.lua文件内容
	
RemoteClient.lua
	接收客户端,lua客户端运行,接收发送客端发送的内容(必须符合lua语法)并执行
	
code.lua
	当双击client.bat时,会自动发送此文件内容(必须符合lua语法)
######################################################################
Noptepad++调用方法:
	按F5,在输入框输入: 文件夹所在路径/client.bat "$(FULL_CURRENT_PATH)"