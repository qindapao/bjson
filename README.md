# bjson
在bash脚本中方便使用JSON。每个函数的使用方法可以参考：`bjson_test.sh`。

## Environmental requirements

The current bash library requires command line tools `gobolt` .
Regarding the construction of the `gobolt` tool, I will sort it out later.
## JSON的对象转换成bash的关联数组

转换后的关联数组中，键是原始值，但是值的话，会增加一个属性标记。所以的属性标记有:

- `s:` 字符串
- `i:` 数字
- `f:` bool false
- `t:` bool true
- `o:` 对象
- `a:` 数组
- `n:` null


## JSON的数组转换成bash的数组

转换后的数组中，数组的每个值都会增加一个属性标记。所以的属性标记和上面相同。

## bash的关联数组转换成JSON的对象

关联数组的每个值的前面都必须打上属性标记的标签。然后才能序列化成JSON对象。

## bash的数组转换成JSON的数组

数组的每个值的前面都必须打上属性标记的标签。然后才能序列化成JSON的数组。


