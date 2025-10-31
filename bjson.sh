[[ "$BJSON_IS_SOURCED" == '1' ]] && return
BJSON_IS_SOURCED=1
BJSON_SOURCE_PATH="${BASH_SOURCE[0]%/*}"
BJSON_CMD="gobolt"
BJSON_EXEC_DIR='/usr/bin'

BJSON_TYPE_NULL=1
BJSON_TYPE_TRUE=2
BJSON_TYPE_FALSE=3
BJSON_TYPE_NUMBER=4
BJSON_TYPE_STR=5
BJSON_TYPE_ARR=6
BJSON_TYPE_OBJ=7
BJSON_TYPE_UNKNOWN=8
BJSON_CODEINTERNALERR=74

# Go 语言 gjson 库版本 v1.18.0
#         sjson 库版本 v1.2.5

BJSON_GO_GJSON_LIB_VERSION='v1.18.0'
BJSON_GO_SJSON_LIB_VERSION='v1.2.5'
BJSON_GO_PRETTY_LIB_VERSION='v1.2.0'

# :TODO: 暂时不做工具版本校验，但是如果后续出现不兼容的情况可能需要增加
# Storage:~/xx # ./gobolt json -m v
# gobolt json version: v1.0.0
# gjson version: v1.18.0
# sjson version: v1.2.5
# pretty version: v1.2.0
# Storage:~/xx # 
# Storage:~/xx # 

# :TODO: 暂时还没有做错误处理。

# 变量命名规则
#   1. 如果函数中包含引用变量，那么必须包含函数名的前缀防呆，使用小驼峰格式
#       如果是引用变量那么加"R"
#       如果是普通变量那么加"V"
#      后面加下划线"_"，下划线的后面是真正的变量名，也是使用小驼峰格式
#   2. 如果函数中没有引用变量，那么使用 小驼峰 的变量命名格式
#   3. 模块内部使用不提供给用户的函数命名，使用下划线开头。
#   4. 函数名都采用 "小写字母+下划线" 的格式命名。
#   5. 全局变量使用 "大写字母+下划线" 的命名格式。
#
# bjson 模块工具初始化
bjson_init ()
{
    which gobolt || {
        cp -f "${BJSON_SOURCE_PATH}/${BJSON_CMD}" "${BJSON_EXEC_DIR}/${BJSON_CMD}"
        chmod +x "${BJSON_EXEC_DIR}/${BJSON_CMD}"
    }
}

# 把一个普通字符串转换成一个JSON字符串
# 超过6666长度的字符串使用工具转换,小字符串使用bash内置
_bjson_quote ()
{
    local -n bjsonQuoteR_str="$1"

    if ((${#bjsonQuoteR_str}>6666)) ; then
        bjsonQuoteR_str=$(printf "%s" "$bjsonQuoteR_str" | gobolt json -m s -k stdin)
    else
        # 反斜杠的处理必须放到最前面
        bjsonQuoteR_str=${bjsonQuoteR_str//\\/\\\\}   # 替换 \ 为 \\
        bjsonQuoteR_str=${bjsonQuoteR_str//\"/\\\"}   # 替换 " 为 \"
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\n'/\\n} # 替换换行符
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\r'/\\r} # 替换回车符
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\t'/\\t} # 替换制表符
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\b'/\\b} # 替换退格符
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\a'/\\a} # 替换响铃符（可选）
        bjsonQuoteR_str=${bjsonQuoteR_str//$'\f'/\\f} # 替换翻页符
        # 嵌入 HTML 时才需要转义
        # bjsonQuoteR_str=${bjsonQuoteR_str//\//\\\/} # 可选

        # 最后双引号包裹字符串
        bjsonQuoteR_str="\"$bjsonQuoteR_str\""
    fi
}

# $1: 需要转换的字符串的值
# $2: 转换后保存的变量名
bjson_key_escape ()
{
    local -n bjsonKeyEscapeR_ekey="$2"

    bjsonKeyEscapeR_ekey="$1"

    if ((${#bjsonKeyEscapeR_ekey}>6666)) ; then
        bjsonKeyEscapeR_ekey=$(printf "%s" "$bjsonKeyEscapeR_ekey" | gobolt json -m e -k stdin)
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey%?}
    else
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'\'/'\\'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'.'/'\.'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'['/'\['}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//']'/'\]'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'*'/'\*'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'?'/'\?'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'|'/'\|'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'@'/'\@'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'!'/'\!'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'#'/'\#'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'{'/'\{'}
        bjsonKeyEscapeR_ekey=${bjsonKeyEscapeR_ekey//'}'/'\}'}
    fi
}

# 关联数组变成JSON字符串
# 关联数组的每个值必须是正确标记类型的值
# $1: 关联数组名
# $2: 结果JSON字符串保存的变量名
bjson_map_to_json () 
{
    local -n bjsonMapToJsonR_map="$1"
    local -n bjsonMapToJsonR_outJson="$2"
    local bjsonMapToJsonV_k bjsonMapToJsonV_v

    (("${#bjsonMapToJsonR_map[@]}")) || {
        bjsonMapToJsonR_outJson="{}"
        return
    }

    bjsonMapToJsonR_outJson="{"
    for bjsonMapToJsonV_k in "${!bjsonMapToJsonR_map[@]}"; do
        bjsonMapToJsonV_v="${bjsonMapToJsonR_map[$bjsonMapToJsonV_k]}"
        _bjson_quote bjsonMapToJsonV_k

        case "${bjsonMapToJsonV_v:0:2}" in
        s:) bjsonMapToJsonV_v=${bjsonMapToJsonV_v:2}
            _bjson_quote bjsonMapToJsonV_v
            ;;
        *)  bjsonMapToJsonV_v=${bjsonMapToJsonV_v:2}
            ;;
        esac

        bjsonMapToJsonR_outJson+="$bjsonMapToJsonV_k:$bjsonMapToJsonV_v,"
    done
    bjsonMapToJsonR_outJson="${bjsonMapToJsonR_outJson%,}}"

    # 按照字典序对键名进行排序
    bjsonMapToJsonR_outJson=$(bjson_r_to_jstr_fstr "$bjsonMapToJsonR_outJson")
}

# 普通数组变成JSON字符串(不考虑稀疏数组的情况)
# 普通数组的每个值必须是正确标记类型的值
# $1: 数组名
# $2: 结果JSON字符串保存的变量名
bjson_arr_to_json ()
{
    local -n bjsonArrToJsonR_arr="$1"
    local -n bjsonArrToJsonR_outJson="$2"
    local bjsonArrToJsonV_item

    (("${#bjsonArrToJsonR_arr[@]}")) || {
        bjsonArrToJsonR_outJson="[]"
        return
    }

    bjsonArrToJsonR_outJson="["
    for bjsonArrToJsonV_item in "${bjsonArrToJsonR_arr[@]}"; do
        case ${bjsonArrToJsonV_item:0:2} in
        s:) bjsonArrToJsonV_item=${bjsonArrToJsonV_item:2}
            _bjson_quote bjsonArrToJsonV_item
            ;;
        *)  bjsonArrToJsonV_item=${bjsonArrToJsonV_item:2}
            ;;
        esac

        bjsonArrToJsonR_outJson+="$bjsonArrToJsonV_item,"
    done
    bjsonArrToJsonR_outJson="${bjsonArrToJsonR_outJson%,}]"

    # 按照好看的格式进行输出(使用多行JSON输出)
    bjsonArrToJsonR_outJson=$(bjson_r_to_jstr_fstr "$bjsonArrToJsonR_outJson")
}

# ---------------------------写入操作组-----------------------------------------
# 数组键如果传 -1 表示追加到数组
# 写入一个字符串到一个JSON文件
# $1: 要写入到的JSON文件名
# $2: 要写入的字符串内容
# $3~: 写入的键序列
# 如果是字典键,那么键的前面加 :, 如果是数组键,那么不需要在前面加 :
# bjson_w_str_to_jfile demo.json "value3 5" :key5 :key6 :key7 0
bjson_w_str_to_jfile ()
{
    gobolt json -m w -k file -i "$1" -s "$2" -P -- "${@:3}"
}


# 写入一个字符串到一个JSON字符串
# 数组键如果传 -1 表示追加到数组
# $1: 要写入到的JSON字符串变量值
# $2: 要写入的字符串内容
# $3~: 写入的键序列
# 如果是字典键,那么键的前面加 :, 如果是数组键,那么不需要在前面加 :
# json_str=$(bjson_w_str_to_jstr "$json_str" "value to write" :key1 :key2 :key3 0)
bjson_w_str_to_jstr ()
{
    printf "%s" "$1" | gobolt json -m w -k stdin -s "$2" -P -- "${@:3}"
}

# 数组键如果传 -1 表示追加到数组
# $1: 输出文件名
# $2: 输入的JSON对象
# $3~: 写入的键序列
bjson_w_jobj_to_jfile ()
{
    gobolt json -m w -k file -i "$1" -j "$2" -P -- "${@:3}"
}

# 这可以防止插入一个超级大的JSON字符串
# $1: 输出文件名
# $2: 输入文件名
# $3~: 写入的键序列
# 数组键如果传 -1 表示追加到数组
bjson_w_jfile_to_jfile ()
{
    gobolt json -m w -k file -i "$1" -f "$2" -P -- "${@:3}"
}

# 数组键如果传 -1 表示追加到数组
bjson_w_jobj_to_jstr ()
{
    printf "%s" "$1" | gobolt json -m w -k stdin -j "$2" -P -- "${@:3}"
}

# 这可以防止插入一个超级大的JSON字符串而超过命令行的参数限制
# 写入一个JSON文件到一个JSON字符串
# $1: 要写入到的JSON字符串变量值
# $2: 要插入的JSON文件名
# $3~: 写入的键序列
bjson_w_jfile_to_jstr ()
{
    printf "%s" "$1" | gobolt json -m w -k stdin -f "$2" -P -- "${@:3}"
}

# 注意: map 中的数字会被当做字符串写入JSON
# $1: 要写入到的JSON字符串变量值
# $2: 要插入的关联数组的变量名
# $3~: 插入的键的序列
bjson_w_map_to_jstr ()
{
    local bjsonWMapToJStrV_mapjStr=''

    bjson_map_to_json "$2" bjsonWMapToJStrV_mapjStr
    bjson_w_jobj_to_jstr "$1" "$bjsonWMapToJStrV_mapjStr" "${@:3}"
}

# 注意: map 中的数字会被当做字符串写入JSON
# $1: 要写入到的JSON文件名
# $2: 要插入的关联数组的变量名
# $3~: 插入的键的序列
bjson_w_map_to_jfile ()
{
    local bjsonWMapToJfileV_mapjStr=''

    bjson_map_to_json "$2" bjsonWMapToJfileV_mapjStr
    bjson_w_jobj_to_jfile "$1" "$bjsonWMapToJfileV_mapjStr" "${@:3}"
}

# 为了更加简单，暂时不支持稀疏数组
# 注意: 数组 中的数字会被当做字符串写入JSON
# $1: 要写入到的JSON字符串变量值
# $2: 要插入的数组的变量名
# $3~: 插入的键的序列
bjson_w_arr_to_jstr ()
{
    local bjsonWArrToJStrV_mapjStr=''

    bjson_arr_to_json "$2" bjsonWArrToJStrV_mapjStr
    bjson_w_jobj_to_jstr "$1" "$bjsonWArrToJStrV_mapjStr" "${@:3}"
}

# 为了更加简单，暂时不支持稀疏数组
# 注意: 数组 中的数字会被当做字符串写入JSON
# $1: 要写入到的JSON文件名
# $2: 要插入的数组的变量名
# $3~: 插入的键的序列
bjson_w_arr_to_jfile ()
{
    local bjsonWArrToJfileV_mapjStr=''

    bjson_arr_to_json "$2" bjsonWArrToJfileV_mapjStr
    bjson_w_jobj_to_jfile "$1" "$bjsonWArrToJfileV_mapjStr" "${@:3}"
}

# -------------------------读取操作组------------------------------------------
# 读取到一个jstr
# $1: 需要读取的文件名
# $2~: 所有的键
bjson_r_to_jstr_ffile ()
{
    gobolt json -m r -t txt -k file -i "$1" -P -- "${@:2}"
}

# 读取到一个变量名
# $1: 需要读取的JSON文件名 # $2~: 读取的键列表
bjson_r_to_var_ffile ()
{
    gobolt json -m r -t sh -k file -i $1 -P -- "${@:2}"
}

# $1: 需要读取的JSON字符串值
# $2~: 所有的键
bjson_r_to_jstr_fstr ()
{
    printf "%s" "$1" | gobolt json -m r -t txt -k stdin -P -- "${@:2}"
}

# 读取到一个变量名
# $1: 需要读取的JSON字符串值
# $2~: 读取的键列表
bjson_r_to_var_fstr ()
{
    printf "%s" "$1" | gobolt json -m r -t sh -k stdin -P -- "${@:2}"
}

# -----------------------------------------属性获取----------------------------

# $1: 需要获取属性的JSON文件名
# $2~: 键列表
# 注意: 这个函数需要判断 $? 来确定类型
bjson_get_attr_ffile ()
{
    gobolt json -m r -t type -k file -i "$1" -P -- "${@:2}"
}

# $1: 需要获取属性的JSON字符串的内容
# $2~: 键列表
# 注意: 这个函数需要判断 $? 来确定类型
bjson_get_attr_fstr ()
{
    printf "%s" "$1" | gobolt json -m r -t type -k stdin -P -- "${@:2}"
}

# -----------------------------------------删除操作组--------------------------

# $1: 需要操作的JSON文件名
# $2~: 需要删除的键列表
bjson_d_ffile ()
{
    gobolt json -m d -k file -i "$1" -P -- "${@:2}"
}

bjson_d_fstr ()
{
    printf "%s" "$1" | gobolt json -m d -k stdin -P -- "${@:2}"
}

# --------------------------------自己构造gjson路径读取------------------------
# 可以支持高级操作，但是需要谨慎使用
# 可以按照gjson的规则传递键，用点号 . 连接
# $1: 需要读取的JSON文件名
# $2: 使用点号链接的路径(路径已经使用 bjson_key_escape 函数处理好)
#     如果需要特殊的查询按照 Go 语言的gjson库的规则构造即可。
bjson_r_to_jstr_ffile_raw ()
{
    gobolt json -m r -t txt -k file -i "$1" -p "$2" -F 'raw'
}

# $1: 需要读取的JSON字符串值
# $2: 使用点号链接的原始路径
bjson_r_to_jstr_fstr_raw ()
{
    printf "%s" "$1" | gobolt json -m r -t txt -k stdin -p "$2" -F 'raw'
}

# $1: 需要读取的JSON文件名
# $2: 使用点号链接的原始路径
bjson_r_to_var_ffile_raw ()
{
    gobolt json -m r -t sh -k file -i "$1" -p "$2" -F 'raw'
}

# $1: 需要读取的JSON字符串值
# $2: 使用点号链接的原始路径
bjson_r_to_var_fstr_raw ()
{
    printf "%s" "$1" | gobolt json -m r -t sh -k stdin -p "$2" -F 'raw'
}

# ---------------------------- 人类更加友好的方式打印 -------------------------
_bjson_line_display_max() {
    awk '
    BEGIN {
        max = 0
    }
    {
        line = $0
        total = length(line)
        wide = gsub(/[\u1100-\u115F\u2E80-\uA4CF\uAC00-\uD7A3\uF900-\uFAFF\uFE30-\uFE4F\uFF00-\uFF60\uFFE0-\uFFE6]/, "")
        width = total + wide * 2
        if (width > max) max = width
    }
    END {
        print max
    }'
}


# $1: 需要读取的JSON字符串
# $2~: 键列表
bjson_bprint_fstr ()
{
    printf "%s" "$1" | gobolt json -m r -t txt -k stdin -F 'human' -P -- "${@:2}"
}

bjson_bprint_ffile ()
{
    gobolt json -m r -t txt -k file -i "$1" -F 'human' -P -- "${@:2}"
}

_bjson_diff ()
{
    local bjson1="$1" bjson2="$2"
    local max1=$(printf "%s" "$bjson1" | _bjson_line_display_max)
    local max2=$(printf "%s" "$bjson2" | _bjson_line_display_max)
    local width=$((max1+max2+10))
    echo "$width"
    diff --minimal --side-by-side --expand-tabs --tabsize=4 --color --width=${width} -y <(printf "%s" "$bjson1") <(printf "%s" "$bjson2")
}

bjson_diff_fstr ()
{
    local json1="$1" json2="$2"
    _bjson_diff "$(bjson_bprint_fstr "$json1")" "$(bjson_bprint_fstr "$json2")"
}

bjson_diff_ffile ()
{
    local jfile1="$1" jfile2="$2"
    _bjson_diff "$(bjson_bprint_ffile "$jfile1")" "$(bjson_bprint_ffile "$jfile2")"
}

# 模块内部使用的函数
readonly -f _bjson_quote
readonly -f _bjson_diff
readonly -f _bjson_line_display_max

# 提供给用户使用的函数
readonly -f bjson_init
readonly -f bjson_map_to_json
readonly -f bjson_arr_to_json
readonly -f bjson_w_str_to_jfile
readonly -f bjson_w_str_to_jstr
readonly -f bjson_w_jobj_to_jfile
readonly -f bjson_w_jfile_to_jfile
readonly -f bjson_w_jobj_to_jstr
readonly -f bjson_w_jfile_to_jstr
readonly -f bjson_w_map_to_jstr
readonly -f bjson_w_map_to_jfile
readonly -f bjson_w_arr_to_jstr
readonly -f bjson_w_arr_to_jfile
readonly -f bjson_r_to_jstr_ffile
readonly -f bjson_r_to_var_ffile
readonly -f bjson_r_to_jstr_fstr
readonly -f bjson_r_to_var_fstr
readonly -f bjson_get_attr_ffile
readonly -f bjson_get_attr_fstr
readonly -f bjson_d_ffile
readonly -f bjson_d_fstr
readonly -f bjson_r_to_jstr_ffile_raw
readonly -f bjson_r_to_jstr_fstr_raw
readonly -f bjson_r_to_var_ffile_raw
readonly -f bjson_r_to_var_fstr_raw
readonly -f bjson_bprint_fstr
readonly -f bjson_bprint_ffile
readonly -f bjson_diff_fstr
readonly -f bjson_diff_ffile

