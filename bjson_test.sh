#!/usr/bin/bash

source ./bjson.sh


test_bjson_w_str_to_jfile ()
{
    local expect_json_str=''

    {
    IFS= read -r -d '' expect_json_str <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                "demo str 1"
            ]
        }
    }
}
    EOF
    } || true
    # 去掉末尾的换行符
    expect_json_str="${expect_json_str%$'\n'}"

    rm -f demo.json
    bjson_w_str_to_jfile demo.json "demo str 1" :key1 :key2 :key3 2

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
    local expect_json_1
    local expect_json_2

    {
    IFS= read -r -d '' expect_json_1 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write"
        }
    }
}
    EOF
    } || true

    {
    IFS= read -r -d '' expect_json_2 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write",
            "key4": "value to write2"
        }
    }
}
    EOF
    } || true

    expect_json_1="${expect_json_1%$'\n'}"
    expect_json_2="${expect_json_2%$'\n'}"

    local json_str

    json_str=$(bjson_w_str_to_jstr "$json_str" "value to write" :key1 :key2 :key3)
    if [[ "$json_str" != "$expect_json_1" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    json_str=$(bjson_w_str_to_jstr "$json_str" "value to write2" :key1 :key2 :key4)
    if [[ "$json_str" != "$expect_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_jobj_to_jfile ()
{
    local expect_json_str=''

    {
    IFS= read -r -d '' expect_json_str <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": [
                null,
                null,
                {
                    "other1": 1,
                    "other2": 2
                },
                null,
                145.3
            ]
        }
    }
}
    EOF
    } || true
    # 去掉末尾的换行符
    expect_json_str="${expect_json_str%$'\n'}"

    rm -f demo.json
    bjson_w_jobj_to_jfile demo.json '{"other1": 1, "other2": 2}' :key1 :key2 :key3 2

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
    local injson_str=''

    {
    IFS= read -r -d '' injson_str <<'    EOF'
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
    EOF
    } || true
    # 去掉末尾的换行符
    injson_str="${injson_str%$'\n'}"
    printf "%s" "$injson_str" > injson.json

    rm -f demo.json
    bjson_w_jfile_to_jfile demo.json 'injson.json' 2

    local expect_json=''
    {
    IFS= read -r -d '' expect_json_str <<'    EOF'
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
                        "other1": 1,
                        "other2": 2
                    }
                ]
            }
        }
    }
]
    EOF
    } || true
    expect_json_str="${expect_json_str%$'\n'}"
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
    local expect_json_1
    local expect_json_2

    {
    IFS= read -r -d '' expect_json_1 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write"
        }
    }
}
    EOF
    } || true

    {
    IFS= read -r -d '' expect_json_2 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write",
            "key4": 109.56
        }
    }
}
    EOF
    } || true

    expect_json_1="${expect_json_1%$'\n'}"
    expect_json_2="${expect_json_2%$'\n'}"

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
    local expect_json_1
    local expect_json_2

    {
    IFS= read -r -d '' expect_json_1 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write"
        }
    }
}
    EOF
    } || true

    {
    IFS= read -r -d '' expect_json_2 <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": "value to write",
            "key4": 109.56
        }
    }
}
    EOF
    } || true

    expect_json_1="${expect_json_1%$'\n'}"
    expect_json_2="${expect_json_2%$'\n'}"

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
    local -A map_test=([key1]=0 [key2]='str')
    local jstr='["value1", "value2"]'

    jstr=$(bjson_w_map_to_jstr "$jstr" map_test 0 3)

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
[
    "value1",
    "value2",
    null,
    {
        "key1": "0",
        "key2": "str"
    }
]
    EOF
    } || true
    expect_json="${expect_json%$'\n'}"

     if [[ "$jstr" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_map_to_jfile ()
{
    local -A map_test=([key1]=0 [key2]='str')
    local jstr='["value1", "value2"]'
    printf "%s" "$jstr" >jfile.json

    bjson_w_map_to_jfile jfile.json map_test 0 3

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
[
    "value1",
    "value2",
    null,
    {
        "key1": "0",
        "key2": "str"
    }
]
    EOF
    } || true
    expect_json="${expect_json%$'\n'}"

    if [[ "$(<jfile.json)" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_arr_to_jstr ()
{
    local -a arr_test=(0 'str')
    local jstr='["value1", "value2"]'

    jstr=$(bjson_w_arr_to_jstr "$jstr" arr_test 0 3)

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
[
    "value1",
    "value2",
    null,
    [
        "0",
        "str"
    ]
]
    EOF
    } || true
    expect_json="${expect_json%$'\n'}"

     if [[ "$jstr" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_w_arr_to_jfile ()
{
    local -a arr_test=(0 'str')
    local jstr='["value1", "value2"]'
    printf "%s" "$jstr" >jfile.json

    bjson_w_arr_to_jfile jfile.json arr_test 0 3

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
[
    "value1",
    "value2",
    null,
    [
        "0",
        "str"
    ]
]
    EOF
    } || true
    expect_json="${expect_json%$'\n'}"

    if [[ "$(<jfile.json)" != "$expect_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_r_to_jstr_ffile_bjson_r_to_jstr_fstr ()
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
                        "other1": "other value\n中文\n",
                        "other2": "2"
                    }
                ]
            }
        }
    }
]
    EOF
    } || true

    printf "%s" "$rjson" > demo1.json


    local child_json=''

    child_json=$(bjson_r_to_jstr_ffile demo1.json 2 key1 key2)

    local expect_json=''
    {
    IFS= read -r -d '' expect_json <<'    EOF'
{
    "key3": [
        null,
        null,
        {
            "other1": "other value\n中文\n",
            "other2": "2"
        }
    ]
}
    EOF
    } || true
    expect_json="${expect_json%$'\n'}"
    
    if [[ "$expect_json" != "$child_json" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    local expect_json_2='"other value\n中文\n"'
    child_json_2=$(bjson_r_to_jstr_ffile demo1.json 2 key1 key2 key3 2 other1)

    if [[ "$expect_json_2" != "$child_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    local demo1_json=$(<demo1.json)
    child_json_2=$(bjson_r_to_jstr_fstr "$demo1_json" 2 key1 key2 key3 2 other1)

    if [[ "$expect_json_2" != "$child_json_2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
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
    local -A map2=()
    eval -- "$(bjson_r_to_var_ffile demo1.json map1 2)"
    
    # declare -p map1

    local str1
    eval -- "$(bjson_r_to_var_ffile demo1.json str1 2 key1 key2 key3 2 other1)"
    # declare -p str1

    local str2 spec2
    spec2=$'1\n中文不对的\n'
    eval -- "$(bjson_r_to_var_fstr "${map1[key1]}" str2 key2 key3 2 other1)"

    if [[ "$str2" != "$spec2" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    # 字典重新组装成JSON
    local json_again

    bjson_map_to_json map1 json_again 1 

    local complex_key=$'oth\n\\\'"$中 文\t'
    local complex_value=''
    eval -- "$(bjson_r_to_var_ffile demo1.json complex_value 2 key1 key2 key3 2 "$complex_key")"

    if [[ "$complex_value" != "this is right" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    local complex_value=''
    eval -- "$(bjson_r_to_var_fstr "$json_again" complex_value key1 key2 key3 2 "$complex_key")"

    if [[ "$complex_value" != "this is right" ]] ; then
        echo "${FUNCNAME[0]} test fail."
        return 1
    fi

    echo "${FUNCNAME[0]} test pass."
    return 0
}

test_bjson_get_attr_ffile ()
{
    local demo_json=''

    {
    IFS= read -r -d '' demo_json <<'    EOF'
{
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
    EOF
    } || true

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
    local demo_json=''

    {
    IFS= read -r -d '' demo_json <<'    EOF'
{
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
    EOF
    } || true

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

    local demo_json=''

    {
    IFS= read -r -d '' demo_json <<'    EOF'
{
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
    EOF
    } || true

    printf "%s" "$demo_json" >demo.json

    bjson_d_ffile demo.json key1 key2 key3 2

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": [
                null,
                null
            ]
        }
    }
}
    EOF
    } || true

    expect_json=${expect_json%$'\n'}
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

    local demo_json=''

    {
    IFS= read -r -d '' demo_json <<'    EOF'
{
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
    EOF
    } || true

    demo_json=$(bjson_d_fstr "$demo_json" key1 key2 key3 2)

    local expect_json=''

    {
    IFS= read -r -d '' expect_json <<'    EOF'
{
    "key1": {
        "key2": {
            "key3": [
                null,
                null
            ]
        }
    }
}
    EOF
    } || true

    expect_json=${expect_json%$'\n'}

    if [[ "$demo_json" != "$expect_json" ]] ; then
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
test_bjson_d_fstr

