----------------------------------------------------------------------
-- 字段类型:
-- key_number,数字关键字(必填),如:10
-- key_string,字符串关键字(必填),如:name
-- number,数字(空数字填:0),如:10
-- string,字符串(空字符串填:nil),如:name
-- list_number,数字列表(空表填:nil),如:4,5,6
-- list_string,字符串列表(空表填:nil),如:name,age
-- tuple_number,数字元组(空元组填:nil),如:{1,2,3},{4,5,6},{7,8,9},{0,1}
-- tuple_string,字符串元组(空元组填:nil),如:{aa,bb,cc},{dd,ee,ff},{gg,hh,ii},{jj,kk}
----------------------------------------------------------------------
return {
	["item_tplt"] = {		-- 物品表
		"key_number.id",		-- id
		"string.name",			-- 名字
		"string.image",			-- 图片
	},
}
----------------------------------------------------------------------