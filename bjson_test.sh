#!/usr/bin/bash

source ./bjson.sh


test_bjson_w_str_to_jfile ()
{
    local expect_json_str='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                "我们看下中文可以不"
            ]
        }
    }
}
'

    rm -f demo.json
    bjson_w_str_to_jfile demo.json "我们看下中文可以不" :key1 :key2 :key3 2

    local demo_json
    IFS= read -r -d '' demo_json <demo.json

    if [[ "$expect_json_str" == "$demo_json" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
    fi

    return 1
}

test_bjson_w_str_to_jstr ()
{
    local expect_json_1='{
    "key1": {
        "key2": {
            "key3": "中文可以吗？"
        }
    }
}'
    local expect_json_2='{
    "key1": {
        "key2": {
            "key3": "中文可以吗？",
            "key4": "value to write2"
        }
    }
}'
    local expect_json_3='{
    "key1": {
        "key2": {
            "key3": "中文可以吗？",
            "key4": "value to write2",
            "key5": ""
        }
    }
}'

    local json_str

    json_str=$(bjson_w_str_to_jstr "$json_str" "中文可以吗？" :key1 :key2 :key3)
    if [[ "$json_str" != "$expect_json_1" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    json_str=$(bjson_w_str_to_jstr "$json_str" "value to write2" :key1 :key2 :key4)
    if [[ "$json_str" != "$expect_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_jobj_to_jfile ()
{
    local expect_json_str='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": "这里是中文的信息哦？",
                    "other2": 2
                },
                null,
                145.3
            ]
        }
    }
}
'
    rm -f demo.json
    bjson_w_jobj_to_jfile demo.json '{"other1": "这里是中文的信息哦？", "other2": 2}' :key1 :key2 :key3 2

    bjson_w_jobj_to_jfile demo.json '145.3' :key1 :key2 :key3 4

    local demo_json
    IFS= read -r -d '' demo_json <demo.json

    if [[ "$expect_json_str" == "$demo_json" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
    fi

    return 1
}

test_bjson_w_jfile_to_jfile ()
{
    local injson_str='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": 1,
                    "other2": 2
                }
            ]
        }
    }
}
'
    printf "%s" "$injson_str" > injson.json

    rm -f demo.json
    bjson_w_jfile_to_jfile demo.json 'injson.json' 2

    local expect_json_str='[
    null,
    null,
    {
        "key1": {
            "key2": {
                "key3": [
                    null,
                    null,
                    {
                        "other1": 1,
                        "other2": 2
                    }
                ]
            }
        }
    }
]'

    if [[ "$expect_json_str" == "$(<demo.json)" ]] ; then
        echo "${FUNCNAME[0]} test pass."
        return 0
    else
        echo "${FUNCNAME[0]} test fail."
    fi

    return 1
}

test_bjson_w_jobj_to_jstr ()
{
    local expect_json_1='{
    "key1": {
        "key2": {
            "key3": "value to write"
        }
    }
}'
    local expect_json_2='{
    "key1": {
        "key2": {
            "key3": "value to write",
            "key4": 109.56
        }
    }
}'

    local json_str

    json_str=$(bjson_w_jobj_to_jstr "$json_str" '"value to write"' :key1 :key2 :key3)
    if [[ "$json_str" != "$expect_json_1" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    json_str=$(bjson_w_jobj_to_jstr "$json_str" '109.56' :key1 :key2 :key4)
    if [[ "$json_str" != "$expect_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0

}

test_bjson_w_jfile_to_jstr ()
{
    local expect_json_1='{
    "key1": {
        "key2": {
            "key3": "value to write"
        }
    }
}'
local expect_json_2='{
    "key1": {
        "key2": {
            "key3": "value to write",
            "key4": 109.56
        }
    }
}'

    printf "%s" '109.56' > expect_json_2.json

    local json_str
    json_str=${expect_json_1}

    json_str=$(bjson_w_jfile_to_jstr "$json_str" 'expect_json_2.json' :key1 :key2 :key4)
    if [[ "$json_str" != "$expect_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_map_to_jstr ()
{
    local -A map_test=(
        [key1]=i:0
        [key2]=s:str
        [key3]=o:'{"value1": 4, "value2": 5}'
        [key4]=f:false
        [key5]=t:true
        [key6]=a:'["item1", 5, "item2", false, true, null]'
        [key7]=n:null
    )
    local jstr='["value1", "value2"]'

    jstr=$(bjson_w_map_to_jstr "$jstr" map_test 3)

    local expect_json='[
    "value1",
    "value2",
    null,
    {
        "key1": 0,
        "key2": "str",
        "key3": {
            "value1": 4,
            "value2": 5
        },
        "key4": false,
        "key5": true,
        "key6": [
            "item1",
            5,
            "item2",
            false,
            true,
            null
        ],
        "key7": null
    }
]'

     if [[ "$jstr" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_map_to_jfile ()
{
    local -A map_test=(
        [key1]=i:0
        [key2]=s:str
        [key3]=o:'{"value1": 4, "value2": 5}'
        [key4]=f:false
        [key5]=t:true
        [key6]=a:'["item1", 5, "item2", false, true, null]'
        [key7]=n:null
    )


    local jstr='["value1", "value2"]'
    printf "%s" "$jstr" >jfile.json

    bjson_w_map_to_jfile jfile.json map_test 3

    local expect_json='[
    "value1",
    "value2",
    null,
    {
        "key1": 0,
        "key2": "str",
        "key3": {
            "value1": 4,
            "value2": 5
        },
        "key4": false,
        "key5": true,
        "key6": [
            "item1",
            5,
            "item2",
            false,
            true,
            null
        ],
        "key7": null
    }
]'

    if [[ "$(<jfile.json)" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_arr_to_jstr ()
{
    local -a arr_test=(
        i:0
        s:str
        o:'{"value1": 4, "value2": 5}'
        f:false
        t:true
        a:'["item1", 5, "item2", false, true, null]'
        n:null
    )
    local jstr='["value1", "value2"]'

    jstr=$(bjson_w_arr_to_jstr "$jstr" arr_test 3)

    local expect_json='[
    "value1",
    "value2",
    null,
    [
        0,
        "str",
        {
            "value1": 4,
            "value2": 5
        },
        false,
        true,
        [
            "item1",
            5,
            "item2",
            false,
            true,
            null
        ],
        null
    ]
]'

     if [[ "$jstr" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_arr_to_jfile ()
{
    local -a arr_test=(
        i:0
        s:str
        o:'{"value1": 4, "value2": 5}'
        f:false
        t:true
        a:'["item1", 5, "item2", false, true, null]'
        n:null
    )
    local jstr='["value1", "value2"]'
    printf "%s" "$jstr" >jfile.json

    bjson_w_arr_to_jfile jfile.json arr_test 3

    local expect_json='[
    "value1",
    "value2",
    null,
    [
        0,
        "str",
        {
            "value1": 4,
            "value2": 5
        },
        false,
        true,
        [
            "item1",
            5,
            "item2",
            false,
            true,
            null
        ],
        null
    ]
]'

    if [[ "$(<jfile.json)" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_jstr_ffile_bjson_r_to_jstr_fstr ()
{
    local rjson='[
    null,
    null,
    {
        "key1": {
            "key2": {
                "{multi1,multi2}": "shold escape!",
                "key3": [
                    null,
                    null,
                    {
                        "other1": "other value\n中文\n",
                        "other2": "2"
                    }
                ]
            }
        }
    }
]
'
    printf "%s" "$rjson" > demo1.json

    local child_json=''

    child_json=$(bjson_r_to_jstr_ffile demo1.json 2 key1 key2)

    local expect_json='{
    "key3": [
        null,
        null,
        {
            "other1": "other value\n中文\n",
            "other2": "2"
        }
    ],
    "{multi1,multi2}": "shold escape!"
}'
    if [[ "$expect_json" != "$child_json" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local expect_json_2='"other value\n中文\n"'
    child_json_2=$(bjson_r_to_jstr_ffile demo1.json 2 key1 key2 key3 2 other1)

    if [[ "$expect_json_2" != "$child_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    local demo1_json=$(<demo1.json)
    child_json_2=$(bjson_r_to_jstr_fstr "$demo1_json" 2 key1 key2 key3 2 other1)

    if [[ "$expect_json_2" != "$child_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    # 验证大括号的转义!
    local multi_path=$(bjson_r_to_jstr_fstr "$demo1_json" 2 key1 key2 '{multi1,multi2}')
    if [[ "$multi_path" != '"shold escape!"' ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_var_ffile_bjson_r_to_var_fstr ()
{
    local rjson=''
    {
    IFS= read -r -d '' rjson <<'    EOF'
[
    null,
    null,
    {
        "key1": {
            "key2": {
                "key3": [
                    null,
                    null,
                    {
                        "other1": "1\n中文不对的\n",
                        "other2": 2,
                        "oth\n\\'\"$中 文\t": "this is right"
                    }
                ]
            }
        }
    }
]
    EOF
    } || true

    printf "%s" "$rjson" > demo1.json

    local -A map1=()
    local json1=""
    
    local output
    output=$(bjson_r_to_var_ffile demo1.json 2)
    eval -- map1=($output)

    local str1
    str1=$(bjson_r_to_var_ffile demo1.json 2 key1 key2 key3 2 other1)
    str1=${str1%?}

    local str_null
    str_null=$(bjson_r_to_var_ffile demo1.json 2 key1 key2 key3 2 othery)

    if [[ "$?" == '0' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local str2 spec2
    spec2=$'1\n中文不对的\n'
    str2=$(bjson_r_to_var_fstr "${map1[key1]:2}" key2 key3 2 other1) ; str2=${str2%?}

    if [[ "$str2" != "$spec2" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    # 字典重新组装成JSON
    local json_again

    bjson_map_to_json map1 json_again 1 

    local complex_key=$'oth\n\\\'"$中 文\t'
    local complex_value=''
    complex_value=$(bjson_r_to_var_ffile demo1.json 2 key1 key2 key3 2 "$complex_key")
    complex_value=${complex_value%?}

    if [[ "$complex_value" != "this is right" ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    local complex_value=''
    complex_value=$(bjson_r_to_var_fstr "$json_again" key1 key2 key3 2 "$complex_key")
    complex_value=${complex_value%?}

    if [[ "$complex_value" != "this is right" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_get_attr_ffile ()
{
    local demo_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": "1\n中文不对的\n",
                    "other2": 2,
					"True": true,
					"False": false,
					"Num": 145.3,
					"str": "xxx",
					"null": null
                }
            ]
        }
    }
}
'

    printf "%s" "$demo_json" > demo.json

    bjson_get_attr_ffile "demo.json" key1 key2
    if [[ "$?" != "$BJSON_TYPE_OBJ" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3
    if [[ "$?" != "$BJSON_TYPE_ARR" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 True
    if [[ "$?" != "$BJSON_TYPE_TRUE" ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 False
    if [[ "$?" != "$BJSON_TYPE_FALSE" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 Num
    if [[ "$?" != "$BJSON_TYPE_NUMBER" ]] ; then
        echo "${FUNCNAME[0]} test fail 5."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 str
    if [[ "$?" != "$BJSON_TYPE_STR" ]] ; then
        echo "${FUNCNAME[0]} test fail 6."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 null
    if [[ "$?" != "$BJSON_TYPE_NULL" ]] ; then
        echo "${FUNCNAME[0]} test fail 7."
        return 1
    fi

    bjson_get_attr_ffile "demo.json" key1 key2 key3 2 null xx
    if [[ "$?" != "$BJSON_CODEINTERNALERR" ]] ; then
        echo "${FUNCNAME[0]} test fail 8."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_get_attr_fstr ()
{
    local demo_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": "1\n中文不对的\n",
                    "other2": 2,
					"True": true,
					"False": false,
					"Num": 145.3,
					"str": "xxx",
					"null": null
                }
            ]
        }
    }
}
'

    bjson_get_attr_fstr "$demo_json" key1 key2
    if [[ "$?" != "$BJSON_TYPE_OBJ" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3
    if [[ "$?" != "$BJSON_TYPE_ARR" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 True
    if [[ "$?" != "$BJSON_TYPE_TRUE" ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 False
    if [[ "$?" != "$BJSON_TYPE_FALSE" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 Num
    if [[ "$?" != "$BJSON_TYPE_NUMBER" ]] ; then
        echo "${FUNCNAME[0]} test fail 5."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 str
    if [[ "$?" != "$BJSON_TYPE_STR" ]] ; then
        echo "${FUNCNAME[0]} test fail 6."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 null
    if [[ "$?" != "$BJSON_TYPE_NULL" ]] ; then
        echo "${FUNCNAME[0]} test fail 7."
        return 1
    fi

    bjson_get_attr_fstr "$demo_json" key1 key2 key3 2 null xx
    if [[ "$?" != "$BJSON_CODEINTERNALERR" ]] ; then
        echo "${FUNCNAME[0]} test fail 8."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_d_ffile ()
{

    local demo_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": "1\n中文不对的\n",
                    "other2": 2,
					"True": true,
					"False": false,
					"Num": 145.3,
					"str": "xxx",
					"null": null
                }
            ]
        }
    }
}
'

    printf "%s" "$demo_json" >demo.json

    bjson_d_ffile demo.json key1 key2 key3 2

    local expect_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null
            ]
        }
    }
}
'

    printf "%s" "$expect_json" >expect.json

    diff demo.json expect.json || {
        echo "${FUNCNAME[0]} test fail."
        return 1
    }

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_d_fstr ()
{

    local demo_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": "1\n中文不对的\n",
                    "other2": 2,
					"True": true,
					"False": false,
					"Num": 145.3,
					"str": "xxx",
					"null": null
                }
            ]
        }
    }
}
'

    demo_json=$(bjson_d_fstr "$demo_json" key1 key2 key3 2)

    local expect_json='{
    "key1": {
        "key2": {
            "key3": [
                null,
                null
            ]
        }
    }
}'

    if [[ "$demo_json" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_map_to_json ()
{
    declare -A xx=(
        [ab]=i:4
        [56]=s:ggege
        [key1]=f:false
        [key2]=t:true
        [key3]=o:'{"key1": 5, "obj2": "str2"}'
        [key4]=a:'["item1", 4, 5, 168.2, "item2"]'
        [key5]=n:null
        [key中文]=s:'中文的信息可以吗？'
        [$'.[0]\\']=s:'特殊的键'
    )
    local jstr=''
    bjson_map_to_json xx jstr
    
    local expect_jstr='{
    ".[0]\\": "特殊的键",
    "56": "ggege",
    "ab": 4,
    "key1": false,
    "key2": true,
    "key3": {
        "key1": 5,
        "obj2": "str2"
    },
    "key4": [
        "item1",
        4,
        5,
        168.2,
        "item2"
    ],
    "key5": null,
    "key中文": "中文的信息可以吗？"
}'

    if [[ "$jstr" != "$expect_jstr" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_arr_to_json ()
{
    declare -a xx=(
        i:4
        s:ggege
        f:false
        t:true
        o:'{"key1": 5, "obj2": "str2"}'
        a:'["item1", 4, 5, 168.2, "item2"]'
        n:null
        s:'我们是中文也可以吗？'
        s:'["json_str", 5]'
    )
    local jstr=''
    bjson_arr_to_json xx jstr

    local expect_jstr='[
    4,
    "ggege",
    false,
    true,
    {
        "key1": 5,
        "obj2": "str2"
    },
    [
        "item1",
        4,
        5,
        168.2,
        "item2"
    ],
    null,
    "我们是中文也可以吗？",
    "[\"json_str\", 5]"
]'

    if [[ "$jstr" != "$expect_jstr" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_nested_consecutively ()
{

    local nested_json=''
    
    {
    IFS= read -r -d '' nested_json <<'    EOF'
[
    null,
    null,
    {
        "key1": {
            "key2": {
                "key3": [
                    null,
                    null,
                    {
                        "other1": "1\n中文不对的\n",
                        "other2": 2,
                        "oth\n\\'\"$中 文\t": "this is right"
                    }
                ]
            }
        }
    }
]
    EOF
    } || true
    local -A map1=() map2=() map3=() map4=()
    local -a arr1=()
    eval -- map1=($(bjson_r_to_var_fstr "$nested_json" 2))
    eval -- map2=($(bjson_r_to_var_fstr "${map1[key1]:2}"))
    eval -- map3=($(bjson_r_to_var_fstr "${map2[key2]:2}"))
    eval -- map4=($(bjson_r_to_var_fstr "${map3[key3]:2}" 2))
    eval -- arr1=($(bjson_r_to_var_fstr "${map3[key3]:2}"))

    local jstr_map jstr_arr
    bjson_map_to_json map4 jstr_map 
    bjson_arr_to_json arr1 jstr_arr 
    
    local expect_json_map=''
    local expect_json_arr=''
    
    {
    IFS= read -r -d '' expect_json_map <<'    EOF'
{
    "oth\n\\'\"$中 文\t": "this is right",
    "other1": "1\n中文不对的\n",
    "other2": 2
}
    EOF
    } || true

    {
    IFS= read -r -d '' expect_json_arr <<'    EOF'
[
    null,
    null,
    {
        "oth\n\\'\"$中 文\t": "this is right",
        "other1": "1\n中文不对的\n",
        "other2": 2
    }
]
    EOF
    } || true

    expect_json_map=${expect_json_map%$'\n'}
    expect_json_arr=${expect_json_arr%$'\n'}

    if [[ "$expect_json_map" != "$jstr_map" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    if [[ "$expect_json_arr" != "$jstr_arr" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_jstr_ffile_raw ()
{
    local demo_json='{
  "name": {"first": "Tom", "last": "Anderson"},
  "age":37,
  "children": ["Sara","Alex","Jack"],
  "fav.movie": "Deer Hunter",
  "friends": [
    {"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]},
    {"first": "Roger", "last": "Craig", "age": 68, "nets": ["fb", "tw"]},
    {"first": "Jane", "last": "Murphy", "age": 47, "nets": ["ig", "tw"]}
  ]
}
'
    printf "%s" "$demo_json" > raw1.json
    local jack ; jack=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'child*.2')

    if [[ "$jack" != '"Jack"' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local sara=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'c?ildren.0')
    if [[ "$sara" != '"Sara"' ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    local raw_str='fav.movie'
    local escape_str ; bjson_key_escape "$raw_str" escape_str
    local escape=$(bjson_r_to_jstr_ffile_raw "raw1.json" "$escape_str")
    if [[ "$escape" != '"Deer Hunter"' ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi
    
    # 测试数组长度
    local arr_len=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#')
    if [[ "$arr_len" != "3" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi
    
    # 过滤数组内容
    local arr_contents ; arr_contents=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#.age')
    local contents_spec='[44,68,47]'

    if [[ "$arr_contents" != "$contents_spec" ]] ; then
        echo "${FUNCNAME[0]} test fail 5."
        return 1
    fi

    # 条件表达式
    local dale=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last=="Murphy").first')
    if [[ "$dale" != '"Dale"' ]] ; then
        echo "${FUNCNAME[0]} test fail 6."
        return 1
    fi

    # 查询所有
    local all=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last=="Murphy")#.first')
    
    if [[ "$all" != '["Dale","Jane"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 7."
        return 1
    fi

    local all2=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(age>45)#.last')

    if [[ "$all2" != '["Craig","Murphy"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 8."
        return 1
    fi

    local d1=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(first%"D*").last')
    if [[ "$d1" != '"Murphy"' ]] ; then
        echo "${FUNCNAME[0]} test fail 9."
        return 1
    fi

    local d2=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(first!%"D*").last')
    if [[ "$d2" != '"Craig"' ]] ; then
        echo "${FUNCNAME[0]} test fail 9."
        return 1
    fi

    local null_obj1=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'children.#(!%"*a*")')
    if [[ "$null_obj1" != '"Alex"' ]] ; then
        echo "${FUNCNAME[0]} test fail 10."
        return 1
    fi

    local null_obj2=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'children.#(%"*a*")#')
    if [[ "$null_obj2" != '["Sara","Jack"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 11."
        return 1
    fi

    # 嵌套数组
    local nested_arr=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(nets.#(=="fb"))#.first')
    if [[ "$nested_arr" != '["Dale","Roger"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 12."
        return 1
    fi

    # 按照真值筛选
    # ~true      Converts true-ish values to true
    # ~false     Converts false-ish and non-existent values to true
    # ~null      Converts null and non-existent values to true
    # ~*         Converts any existing value to true
    
    local bool_example='{
  "vals": [
    { "a": 1, "b": "data" },
    { "a": 2, "b": true },
    { "a": 3, "b": false },
    { "a": 4, "b": "0" },
    { "a": 5, "b": 0 },
    { "a": 6, "b": "1" },
    { "a": 7, "b": 1 },
    { "a": 8, "b": "true" },
    { "a": 9, "b": false },
    { "a": 10, "b": null },
    { "a": 11 }
  ]
}
'
    printf "%s" "$bool_example" > bool.json

    local bool1=$(bjson_r_to_jstr_ffile_raw "bool.json" 'vals.#(b==~true)#.a')
    if [[ "$bool1" != '[2,6,7,8]' ]] ; then
        echo "${FUNCNAME[0]} test fail 13."
        return 1
    fi

    local bool2=$(bjson_r_to_jstr_ffile_raw "bool.json" 'vals.#(b==~false)#.a')
    if [[ "$bool2" != '[3,4,5,9,10,11]' ]] ; then
        echo "${FUNCNAME[0]} test fail 14."
        return 1
    fi

    # null 和 explicit
    local null1=$(bjson_r_to_jstr_ffile_raw "bool.json" 'vals.#(b==~null)#.a')
    if [[ "$null1" != '[10,11]' ]] ; then
        echo "${FUNCNAME[0]} test fail 15."
        return 1
    fi

    local explicit1=$(bjson_r_to_jstr_ffile_raw "bool.json" 'vals.#(b==~*)#.a')
    if [[ "$explicit1" != '[1,2,3,4,5,6,7,8,9,10]' ]] ; then
        echo "${FUNCNAME[0]} test fail 16."
        return 1
    fi

    local explicit2=$(bjson_r_to_jstr_ffile_raw "bool.json" 'vals.#(b!=~*)#.a')
    if [[ "$explicit2" != '[11]' ]] ; then
        echo "${FUNCNAME[0]} test fail 17."
        return 1
    fi
    
    # .分隔符和|分隔符测试
    local dale_dot=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.0.first')
    if [[ "$dale_dot" != '"Dale"' ]] ; then
        echo "${FUNCNAME[0]} test fail 18."
        return 1
    fi

    local dale_pipe=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends|0.first')
    if [[ "$dale_pipe" != '"Dale"' ]] ; then
        echo "${FUNCNAME[0]} test fail 19."
        return 1
    fi

    local dale_pipe2=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.0|first')
    if [[ "$dale_pipe2" != '"Dale"' ]] ; then
        echo "${FUNCNAME[0]} test fail 20."
        return 1
    fi

    local dale_pipe3=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends|0|first')
    if [[ "$dale_pipe3" != '"Dale"' ]] ; then
        echo "${FUNCNAME[0]} test fail 21."
        return 1
    fi

    local pipe_len=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends|#')
    if [[ "$pipe_len" != "3" ]] ; then
        echo "${FUNCNAME[0]} test fail 22."
        return 1
    fi

    local dot_len=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#')
    if [[ "$dot_len" != "3" ]] ; then
        echo "${FUNCNAME[0]} test fail 23."
        return 1
    fi

    local test_filter1=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#')
    local expect_test_filter1=''
    expect_test_filter1='[{"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]},{"first": "Jane", "last": "Murphy", "age": 47, "nets": ["ig", "tw"]}]'

    if [[ "$expect_test_filter1" != "$test_filter1" ]] ; then
        echo "${FUNCNAME[0]} test fail 24."
        return 1
    fi

    local test_filter2=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#.first')
    if [[ "$test_filter2" != '["Dale","Jane"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 25."
        return 1
    fi
    
    local test_filter3=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#|first')
    if [[ -n "$test_filter3" ]] ; then
        echo "${FUNCNAME[0]} test fail 26."
        return 1
    fi

    local test_filter4=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#.0')
    if [[ "$test_filter4" != '[]' ]]  ; then
        echo "${FUNCNAME[0]} test fail 27."
        return 1
    fi

    local test_filter5=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#|0')

    if [[ "$test_filter5" != '{"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]}' ]] ; then
        echo "${FUNCNAME[0]} test fail 28."
        return 1
    fi

    local test_filter6=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#.#')
    if [[ "$test_filter6" != '[]' ]] ; then
        echo "${FUNCNAME[0]} test fail 29."
        return 1
    fi

    local test_filter7=$(bjson_r_to_jstr_ffile_raw "raw1.json" 'friends.#(last="Murphy")#|#')
    if [[ "$test_filter7" != "2" ]] ; then
        echo "${FUNCNAME[0]} test fail 30."
        return 1
    fi

    # 测试modifier
    # reverse
    local modifier1='{
  "children": ["Sara", "Alex", "Jack"]
}'

    printf "%s" "$modifier1" > modifier1.json

    local reverse_json=''
    reverse_json=$(bjson_r_to_jstr_ffile_raw 'modifier1.json' 'children.@reverse')

    if [[ "$reverse_json" != '["Jack","Alex","Sara"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 31."
        return 1
    fi
    # ugly
    local ugly=''
    ugly=$(bjson_r_to_jstr_ffile_raw 'modifier1.json' '@ugly')
    if [[ "$ugly" != '{"children":["Sara","Alex","Jack"]}' ]] ; then
        echo "${FUNCNAME[0]} test fail 32."
        return 1
    fi

    # pretty
    local pretty=''
    pretty=$(bjson_r_to_jstr_ffile_raw 'modifier1.json' '@pretty:{"sortKeys":true,"indent":"    ","prefix": "","width": 0}')
    
    local pretty_expect='{
    "children": [
        "Sara",
        "Alex",
        "Jack"
    ]
}'

    if [[ "$pretty_expect" != "$pretty" ]] ; then
        echo "${FUNCNAME[0]} test fail 33."
        return 1
    fi

    # this
    local test_this='
{
  "users": [
    { "name": "张三", "age": 25 },
    { "name": "李四", "age": 30 }
  ]
}
'
    printf "%s" "$test_this" > zhangshan.json
    # 获取名字是张三的完整对象
    local obj_a=$(bjson_r_to_jstr_ffile_raw 'zhangshan.json' 'users.#(name=="张三").@this')

    if [[ "$obj_a" != '{ "name": "张三", "age": 25 }' ]] ; then
        echo "${FUNCNAME[0]} test fail 34."
        return 1
    fi
    
    # valid(校验JSON是否有效)
    local invalid_json='
    { "xx": 56, yy: "dd" }
    '
    printf "%s" "$invalid_json" > invalid.json

    local invalid_var=''
    invalid_var=$(bjson_r_to_jstr_ffile_raw 'invalid.json' '@valid')
    if [[ "$?" != "74" ]] ; then
        echo "${FUNCNAME[0]} test fail 35."
        return 1
    fi

    # flatten 扁平化一个数组
    local flatten='[ [1, 2], [5, 6] ]'
    printf "%s" "$flatten" > flatten.json
    local flatten_ed=$(bjson_r_to_jstr_ffile_raw 'flatten.json' '@flatten')

    if [[ "$flatten_ed" != '[1, 2,5, 6]' ]] ; then
        echo "${FUNCNAME[0]} test fail 36."
        return 1
    fi
    
    # join
    # join dict arr to a dict
    local obj_arr='[
  { "a": 1 },
  { "b": 2 },
  { "c": 3 }
]'
    printf "%s" "$obj_arr" > obj_arr.json
    local obj_arr_join=''
    obj_arr_join=$(bjson_r_to_jstr_ffile_raw 'obj_arr.json' '@join')
    if [[ '{"a":1,"b":2,"c":3}' != "$obj_arr_join" ]] ; then
        echo "${FUNCNAME[0]} test fail 37."
        return 1
    fi
    
    # keys(返回一个对象中所有的键,可以用于遍历)
    local keys=$(bjson_r_to_jstr_ffile_raw 'raw1.json' 'name.@keys')
    if [[ "$keys" != '["first","last"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 38."
        return 1
    fi

    # values(返回一个对象中所有的值)
    local values=$(bjson_r_to_jstr_ffile_raw 'raw1.json' 'name.@values')
    if [[ "$values" != '["Tom","Anderson"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 39."
        return 1
    fi
    
    # tostr(包装一个JSON字符串成一个普通字符串) --- 这个并没有多大意义!
    local tostr=$(bjson_r_to_jstr_ffile_raw 'raw1.json' 'name.@tostr')
    if [[ "$tostr" != '"{\"first\": \"Tom\", \"last\": \"Anderson\"}"' ]] ; then
        echo "${FUNCNAME[0]} test fail 40."
        return 1
    fi
    
    # fromstr(从字符串中还原出JSON字符串)
    local fromstr=$(bjson_r_to_jstr_ffile_raw 'raw1.json' 'name.@tostr.@fromstr')
    if [[ "$fromstr" != '{"first": "Tom", "last": "Anderson"}' ]] ; then
        echo "${FUNCNAME[0]} test fail 41."
        return 1
    fi
    
    # @group: Groups arrays of objects.
    # 合并成对象数组
    local ori_json='
{
  "id": ["123", "456", "789"],
  "val": [2, 1]
}'

    printf "%s" "$ori_json" > group.json

    local group_obj=$(bjson_r_to_jstr_ffile_raw 'group.json' '@group')

    if [[ "$group_obj" != '[{"id":"123","val":2},{"id":"456","val":1},{"id":"789"}]' ]] ; then
        echo "${FUNCNAME[0]} test fail 42."
        return 1
    fi


    # dig(搜索某个字段的值)
    # 所有匹配的结果放到数组中
    local nested_obj='
{
  "user": {
    "profile": {
      "name": "Alice"
    }
  },
  "admin": {
    "info": {
      "name": ["Bob", "xxy", {"name": "name in name"}]
    }
  }
}
    '
    
    printf "%s" "$nested_obj" > nested.json

    local dig_value=$(bjson_r_to_jstr_ffile_raw 'nested.json' '@dig:name')

    if [[ "$dig_value" != '["Alice",["Bob", "xxy", {"name": "name in name"}],"name in name"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 43."
        return 1
    fi

    # 高级用法 JSON Literals
    local literal_ori='
{
  "user": {
    "name": "Alice",
    "age": 30
  }
}
    '

    printf "%s" "$literal_ori" > literal.json

    # multi path的语法中不允许空格
    local literal_after=$(bjson_r_to_jstr_ffile_raw 'literal.json' '{user.name,"role":!"admin","active":!true}')

    if [[ "$literal_after" != '{"name":"Alice","role":"admin","active":true}' ]] ; then
        echo "${FUNCNAME[0]} test fail 44."
        return 1
    fi

    local multi_path_1='{
    "{name,data}": "这是一个键名",
    "name": "张三",
    "data": "内容"
}'
    printf "%s" "$multi_path_1" > multi1.json

    local multi_path_2='{
    "name": "张三",
    "data": "内容"
}'
    printf "%s" "$multi_path_2" > multi2.json
    
    local escape_key ; bjson_key_escape '{name,data}' escape_key
    local value=$(bjson_r_to_jstr_ffile_raw 'multi1.json' "$escape_key")
    local multi_resut=$(bjson_r_to_jstr_ffile_raw 'multi2.json' '{name,data}')
    local name_value=$(bjson_r_to_jstr_ffile_raw 'multi1.json' 'name')

    if [[ "$value" != '"这是一个键名"' ]] ||
        [[ "$multi_resut" != '{"name":"张三","data":"内容"}' ]] ||
        [[ "$name_value" != '"张三"' ]] ; then
        echo "${FUNCNAME[0]} test fail 45."
        return 1
    fi
    
    local complex_multi_path='
{
  "students": [
    {"name": "小明", "score": 88},
    {"name": "小红", "score": 92}
  ],
  "teachers": [
    {"name": "王老师", "subject": "数学"},
    {"name": "李老师", "subject": "语文"}
  ],
  "staff": [
    {"name": "张工", "role": "保安"},
    {"name": "刘姐", "role": "食堂"}
  ],
  "[students,teachers]": 1.4555
}
    '
    printf "%s" "$complex_multi_path" >complex_multi.json

    local complex_multi1=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' '{students,teachers}')
    if [[ "$complex_multi1" != '{"students":[
    {"name": "小明", "score": 88},
    {"name": "小红", "score": 92}
  ],"teachers":[
    {"name": "王老师", "subject": "数学"},
    {"name": "李老师", "subject": "语文"}
  ]}' ]] ; then
        echo "${FUNCNAME[0]} test fail 46."
        return 1
    fi

    local complex_multi2=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' '[students,teachers]')
    if [[ "$complex_multi2" != '[[
    {"name": "小明", "score": 88},
    {"name": "小红", "score": 92}
  ],[
    {"name": "王老师", "subject": "数学"},
    {"name": "李老师", "subject": "语文"}
  ]]' ]] ; then
        echo "${FUNCNAME[0]} test fail 47."
        return 1
    fi

    local complex_multi3=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' '{students.0.name,teachers.1.subject}')
    if [[ "$complex_multi3" != '{"name":"小明","subject":"语文"}' ]] ; then
        echo "${FUNCNAME[0]} test fail 48."
        return 1
    fi

    local complex_multi4=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' '[students.1.score,staff.0.role]')
    if [[ "$complex_multi4" != '[92,"保安"]' ]] ; then
        echo "${FUNCNAME[0]} test fail 49."
        return 1
    fi

    local complex_multi5=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' '{students.#.name,teachers.#.name}')
    if [[ "$complex_multi5" != '{"name":["小明","小红"],"name":["王老师","李老师"]}' ]] ; then
        echo "${FUNCNAME[0]} test fail 50."
        return 1
    fi

    local escape_key ; bjson_key_escape '[students,teachers]' escape_key
    local complex_multi6=$(bjson_r_to_jstr_ffile_raw 'complex_multi.json' "$escape_key")
    if [[ "$complex_multi6" != '1.4555' ]] ; then
        echo "${FUNCNAME[0]} test fail 51."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_jstr_fstr_raw ()
{
    local demo_json='{
  "name": {"first": "Tom", "last": "Anderson"},
  "age":37,
  "children": ["Sara","Alex","Jack"],
  "fav.movie": "Deer Hunter",
  "friends": [
    {"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]},
    {"first": "Roger", "last": "Craig", "age": 68, "nets": ["fb", "tw"]},
    {"first": "Jane", "last": "Murphy", "age": 47, "nets": ["ig", "tw"]}
  ]
}
'
    local jack=$(bjson_r_to_jstr_fstr_raw "$demo_json" 'child*.2')

    if [[ "$jack" != '"Jack"' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local sara=$(bjson_r_to_jstr_fstr_raw "$demo_json" 'c?ildren.0')
    if [[ "$sara" != '"Sara"' ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    local raw_str='fav.movie'
    local escape_str ; bjson_key_escape "$raw_str" escape_str
    local escape=$(bjson_r_to_jstr_fstr_raw "$demo_json" "$escape_str")
    if [[ "$escape" != '"Deer Hunter"' ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_var_ffile_raw ()
{
    local demo_json='{
  "name": {"first": "Tom", "last": "Anderson"},
  "age":37,
  "children": ["Sara","Alex","Jack"],
  "fav.movie": "Deer Hunter",
  "friends": [
    {"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]},
    {"first": "Roger", "last": "Craig", "age": 68, "nets": ["fb", "tw"]},
    {"first": "Jane", "last": "Murphy", "age": 47, "nets": ["ig", "tw"]}
  ]
}
'
    printf "%s" "$demo_json" > raw1.json

    local jack=$(bjson_r_to_var_ffile_raw "raw1.json" 'child*.2')
    jack=${jack%?}
    if [[ "${jack}" != 'Jack' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local sara=$(bjson_r_to_var_ffile_raw "raw1.json" 'c?ildren.0')
    sara=${sara%?}
    if [[ "$sara" != 'Sara' ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    local raw_str='fav.movie'
    local escape_str ; bjson_key_escape "$raw_str" escape_str
    local escape=$(bjson_r_to_var_ffile_raw "raw1.json" "$escape_str")
    escape=${escape%?}
    if [[ "$escape" != 'Deer Hunter' ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi


    eval -- local -a all2=($(bjson_r_to_var_ffile_raw "raw1.json" 'friends.#(age>45)#.last'))

    local x ; printf -v x "%s" "${all2[*]@A}"
    if [[ "$x" != "declare -a all2=([0]=\"s:Craig\" [1]=\"s:Murphy\")" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi


    eval -- local -A fromstr=($(bjson_r_to_var_ffile_raw 'raw1.json' 'name.@tostr.@fromstr'))
    printf -v x "%s" "${fromstr[*]@A}"
    if [[ "$x" != "declare -A fromstr=([last]=\"s:Anderson\" [first]=\"s:Tom\" )" ]] ; then
        echo "${FUNCNAME[0]} test fail 5."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_var_fstr_raw ()
{
    local demo_json='{
  "name": {"first": "Tom", "last": "Anderson"},
  "age":37,
  "children": ["Sara","Alex","Jack"],
  "fav.movie": "Deer Hunter",
  "friends": [
    {"first": "Dale", "last": "Murphy", "age": 44, "nets": ["ig", "fb", "tw"]},
    {"first": "Roger", "last": "Craig", "age": 68, "nets": ["fb", "tw"]},
    {"first": "Jane", "last": "Murphy", "age": 47, "nets": ["ig", "tw"]}
  ]
}
'
    local jack=$(bjson_r_to_var_fstr_raw "$demo_json" 'child*.2')
    jack=${jack%?}
    if [[ "${jack}" != 'Jack' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    local sara=$(bjson_r_to_var_fstr_raw "$demo_json" 'c?ildren.0')
    sara=${sara%?}
    if [[ "$sara" != 'Sara' ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    fi

    local raw_str='fav.movie'
    local escape_str ; bjson_key_escape "$raw_str" escape_str
    local escape=$(bjson_r_to_var_fstr_raw "$demo_json" "$escape_str")
    escape=${escape%?}
    if [[ "$escape" != 'Deer Hunter' ]] ; then
        echo "${FUNCNAME[0]} test fail 3."
        return 1
    fi

    eval -- local -a all2=($(bjson_r_to_var_fstr_raw "$demo_json" 'friends.#(age>45)#.last'))

    local x ; printf -v x "%s" "${all2[*]@A}"
    if [[ "$x" != "declare -a all2=([0]=\"s:Craig\" [1]=\"s:Murphy\")" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    fi


    eval -- local -A fromstr=($(bjson_r_to_var_fstr_raw "$demo_json" 'name.@tostr.@fromstr'))
    printf -v x "%s" "${fromstr[*]@A}"
    if [[ "$x" != "declare -A fromstr=([last]=\"s:Anderson\" [first]=\"s:Tom\" )" ]] ; then
        echo "${FUNCNAME[0]} test fail 5."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_var_fstr_null_and_type ()
{
    local null_obj_arr='
    {
        "key1": 2,
        "key2": {},
        "key3": [],
        "key4": "",
        "key5": null,
        "key6": true,
        "key7": false
    }
    '
    local output=''

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key1)
    if [[ "$?" != "$BJSON_TYPE_NUMBER" || "${output%?}" != "2" ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key3)
    if [[ "$?" != "$BJSON_TYPE_ARR" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    else
        eval -- local -a null_arr=($output)
        if ((${#null_arr[@]}!=0)) ; then
            echo "${FUNCNAME[0]} test fail 3."
            return 1
        fi
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key2)
    if [[ "$?" != "$BJSON_TYPE_OBJ" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    else
        eval -- local -A null_dict=($output)
        if ((${#null_dict[@]}!=0)) ; then
            echo "${FUNCNAME[0]} test fail 5."
            return 1
        fi
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key4)
    if [[ "$?" != "${BJSON_TYPE_STR}" || -n "${output%?}" ]] ; then
        echo "${FUNCNAME[0]} test fail 6."
        return 1
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key5)
    if [[ "$?" != "${BJSON_TYPE_NULL}" || -n "${output%?}" ]] ; then
        echo "${FUNCNAME[0]} test fail 7."
        return 1
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key6)
    if [[ "$?" != "${BJSON_TYPE_TRUE}" || "${output%?}" != "true" ]] ; then
        echo "${FUNCNAME[0]} test fail 8."
        return 1
    fi

    output=$(bjson_r_to_var_fstr "$null_obj_arr" key7)
    if [[ "$?" != "${BJSON_TYPE_FALSE}" || "${output%?}" != "false" ]] ; then
        echo "${FUNCNAME[0]} test fail 9."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_jstr_fstr_null_and_type ()
{
    local null_obj_arr='
    {
        "key1": 2,
        "key2": {},
        "key3": [],
        "key4": "",
        "key5": null,
        "key6": true,
        "key7": false
    }
    '
    local output=''

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key1)
    if [[ "$?" != "$BJSON_TYPE_NUMBER" || "${output}" != '2' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key3)
    if [[ "$?" != "$BJSON_TYPE_ARR" ]] ; then
        echo "${FUNCNAME[0]} test fail 2."
        return 1
    else
        if [[ "$output" != '[]' ]] ; then
            echo "${FUNCNAME[0]} test fail 3."
            return 1
        fi
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key2)
    if [[ "$?" != "$BJSON_TYPE_OBJ" ]] ; then
        echo "${FUNCNAME[0]} test fail 4."
        return 1
    else
        if [[ "$output" != '{}' ]] ; then
            echo "${FUNCNAME[0]} test fail 5."
            return 1
        fi
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key4)
    if [[ "$?" != "${BJSON_TYPE_STR}" || "$output" != '""' ]] ; then
        echo "${FUNCNAME[0]} test fail 6."
        return 1
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key5)
    if [[ "$?" != "${BJSON_TYPE_NULL}" || "$output" != 'null' ]] ; then
        echo "${FUNCNAME[0]} test fail 7."
        return 1
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key6)
    if [[ "$?" != "${BJSON_TYPE_TRUE}" || "${output}" != "true" ]] ; then
        echo "${FUNCNAME[0]} test fail 8."
        return 1
    fi

    output=$(bjson_r_to_jstr_fstr "$null_obj_arr" key7)
    if [[ "$?" != "${BJSON_TYPE_FALSE}" || "${output}" != "false" ]] ; then
        echo "${FUNCNAME[0]} test fail 9."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_beauty_print ()
{
    local demo2='[
    null,
    null,
    {
        "key1": {
            "key2": {
                "key3": [
                    null,
                    null,
                    {
                        "2": 1234.233,
                        "3": true,
                        "4": false,
                        "5": null,
                        "6": [],
                        "7": {},
                        "8": "str",
                        "oth\n\\\"$中 文\t": "this is right",
                        "other1": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "other2": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "other3": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "other4": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "other5": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "other6": "1\n中带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带带的文对的看下全没有全\n",
                        "othex2": 2,
                        "ddge": 5
                    }
                ]
            }
        }
    }
]'
    local demo3='[
    null,
    null,
    {
        "key1": {
            "key2": {
                "key3": [
                    null,
                    null,
                    {
                        "2": 1234.233,
                        "3": true,
                        "4": false,
                        "5": null,
                        "6": [],
                        "7": {},
                        "8": "str",
                        "oth\n\\\"$中 文\t": "this is right",
                        "other1": "1\n中文不对的\n",
                        "xx": "1\n中文不对的\n",
                        "yy": "1\n中文不对的\n",
                        "kk": "1\n中文不对的\n",
                        "不对": "1\n中文不对的\n",
                        "jgjgegeg的": "1\n中文不对的\n",
                        "等更更更": 2,
						"gegeegeeee": 4
                    }
                ]
            }
        }
    }
]'

    printf "%s" "$demo2" > demo2.json
    printf "%s" "$demo3" > demo3.json
    # bjson_bprint_fstr "$demo2"
    bjson_bprint_ffile "demo2.json" > demo2_check.txt

    bjson_diff_fstr "$demo2" "$demo3" > diff1.txt
    bjson_diff_ffile "demo2.json" "demo3.json" > diff2.txt

    # 因为上面diff的结果非0
    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_line_dispaly_max ()
{
    local demo='我是谁
其实这个不重要哈哈哈哈哈m
ddddddddddddddddd
'

    local max=$(printf "%s" "$demo" | _bjson_line_display_max)
    if [[ "$max" != '25' ]] ; then
        echo "${FUNCNAME[0]} test fail 1."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test__bjson_quote ()
{
    local -A test_cases=(
        ["hello world"]='"hello world"'
        ["line1\nline2"]='"line1\\nline2"'
        ["tab\tseparated"]='"tab\\tseparated"'
        ["quote\"inside"]='"quote\"inside"'
        ["backslash\\inside"]='"backslash\\inside"'
        [$'x0\x00']='"x0"'
        [$'\x01x1']='"\u0001x1"'
        [$'\x02x2']='"\u0002x2"'
        [$'\x03x3']='"\u0003x3"'
        [$'\x04x4']='"\u0004x4"'
        [$'\x05x5']='"\u0005x5"'
        [$'\x06x6']='"\u0006x6"'
        [$'\x07x7']='"\u0007x7"'
        [$'\x08x8']='"\bx8"'
        [$'\x09x9']='"\tx9"'
        [$'\x0axa']='"\nxa"'
        [$'\x0bxb']='"\u000bxb"'
        [$'\x0cxc']='"\fxc"'
        [$'\x0dxd']='"xd"'
        [$'\x0exe']='"\u000exe"'
        [$'\x0fxf']='"\u000fxf"'
        [$'\x10x10']='"\u0010x10"'
        [$'\x11x11']='"\u0011x11"'
        [$'\x12x12']='"\u0012x12"'
        [$'\x13x13']='"\u0013x13"'
        [$'\x14x14']='"\u0014x14"'
        [$'\x15x15']='"\u0015x15"'
        [$'\x16x16']='"\u0016x16"'
        [$'\x17x17']='"\u0017x17"'
        [$'\x18x18']='"\u0018x18"'
        [$'\x19x19']='"\u0019x19"'
        [$'\x1ax1a']='"\u001ax1a"'
        [$'\x1bx1b']='"\u001bx1b"'
        [$'\x1cx1c']='"\u001cx1c"'
        [$'\x1dx1d']='"\u001dx1d"'
        [$'\x1ex1e']='"\u001ex1e"'
        [$'\x1fx1f']='"\u001fx1f"'
        [$'\x7fx7F']='"x7F"'
        [$'\x32x32']='"2x32"'
        [$'null\x00char']='"null"'
        ["中文"]='"中文"'
    )
    local s
    for s in "${!test_cases[@]}"; do
        local tmp="$s"
        _bjson_quote tmp
        if [[ "$tmp" != "${test_cases[$s]}" ]] ; then
            echo "------"
            echo "原始:      [$s]"
            echo "JSON:      [$tmp]"
            echo "JSON SPEC: [${test_cases[$s]}]"
            
            echo "${FUNCNAME[0]} test fail."
            return 1
        fi
    done
    echo "${FUNCNAME[0]} test pass."
    return 0
}

# 当前msys2的bash发现一个BUG，$'\r'出现在数组定义的字面量中的时候会被丢弃
# arr=($'\r') 这是无效的
# arr[0]=$'\r' 这样才可以
test_invisible_characters ()
{
    # $'\000'  # NUL (0)
    # $'\001'  # SOH (1)
    # $'\002'  # STX (2)
    # $'\003'  # ETX (3)
    # $'\004'  # EOT (4)
    # $'\005'  # ENQ (5)
    # $'\006'  # ACK (6)
    # $'\007'  # BEL (7)
    # $'\010'  # BS  (8)
    # $'\011'  # HT  (9)
    # $'\012'  # LF  (10)
    # $'\013'  # VT  (11)
    # $'\014'  # FF  (12)
    # $'\015'  # CR  (13)
    # $'\016'  # SO  (14)
    # $'\017'  # SI  (15)
    # $'\020'  # DLE (16)
    # $'\021'  # DC1 (17)
    # $'\022'  # DC2 (18)
    # $'\023'  # DC3 (19)
    # $'\024'  # DC4 (20)
    # $'\025'  # NAK (21)
    # $'\026'  # SYN (22)
    # $'\027'  # ETB (23)
    # $'\030'  # CAN (24)
    # $'\031'  # EM  (25)
    # $'\032'  # SUB (26)
    # $'\033'  # ESC (27)
    # $'\034'  # FS  (28)
    # $'\035'  # GS  (29)
    # $'\036'  # RS  (30)
    # $'\037'  # US  (31)
    # $'\177'  # DEL (127)
    local -a invisible_values=(
        # \000 会被Go的JSON库截断，后面的字符都不会再出现了
        # 所以这里不插入\000字符
        ""
        $'s:\u200B\u200C\u200D\uFEFF\u2060\u180E'
        )

    invisible_values[0]=$'s:\E\a\b\t\n\v\f\r\\\'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177'
    invisible_values[2]=$'s:\b\t\n\f\r\\\''

    local json_str
    json_str=$(bjson_w_arr_to_jstr '{}' invisible_values "invalid")
    local null_1 null_2 null_3
    null_1=$(bjson_r_to_var_fstr "$json_str" invalid 0)
    null_2=$(bjson_r_to_var_fstr "$json_str" invalid 1)
    null_3=$(bjson_r_to_var_fstr "$json_str" invalid 2)
    local spec1 spec2 spec3
    spec1=$'\E\a\b\t\n\v\f\r\\\'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177'
    spec2=$'\u200B\u200C\u200D\uFEFF\u2060\u180E'
    spec3=$'\b\t\n\f\r\\\''
    
    if [[ "${null_1%?}" != "$spec1" ]] ||
        [[ "${null_2%?}" != "$spec2" ]] ||
        [[ "${null_3%?}" != "$spec3" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

# :TODO: 增加读取的情况下，连续嵌套的时候是否能正确。
bjson_init &&
test_bjson_w_str_to_jfile &&
test_bjson_w_str_to_jstr &&
test_bjson_w_jobj_to_jfile &&
test_bjson_w_jfile_to_jfile &&
test_bjson_w_jobj_to_jstr &&
test_bjson_w_jfile_to_jstr &&
test_bjson_w_map_to_jstr &&
test_bjson_w_map_to_jfile &&
test_bjson_w_arr_to_jstr &&
test_bjson_w_arr_to_jfile &&
test_bjson_r_to_jstr_ffile_bjson_r_to_jstr_fstr &&
test_bjson_r_to_var_ffile_bjson_r_to_var_fstr &&
test_bjson_get_attr_ffile &&
test_bjson_get_attr_fstr &&
test_bjson_d_ffile &&
test_bjson_d_fstr &&
test_bjson_map_to_json &&
test_bjson_arr_to_json &&
test_nested_consecutively &&
test_bjson_r_to_jstr_ffile_raw &&
test_bjson_r_to_jstr_fstr_raw &&
test_bjson_r_to_var_ffile_raw &&
test_bjson_r_to_var_fstr_raw &&
test_bjson_r_to_var_fstr_null_and_type &&
test_bjson_r_to_jstr_fstr_null_and_type &&
test_beauty_print &&
test_bjson_line_dispaly_max &&
test__bjson_quote &&
test_invisible_characters

