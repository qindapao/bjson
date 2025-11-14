# bjson

Convenient use of JSON in bash scripts. For how to use each function, please refer to: `bjson_test.sh`.

## Environmental requirements

The current bash library requires command line tools [gobolt](https://github.com/qindapao/common_tool) .

## Convert JSON object to bash associative array

In the converted associative array, the key is the original value, but for the value, an attribute tag will be added. So the attribute tags have:

- `s:` string
- `i:` number
- `f:` bool false
- `t:` bool true
- `o:` object
- `a:` array
- `n:` null


## Convert JSON array to bash array

In the converted array, an attribute tag will be added to each value of the array. All attribute tags are the same as above.

## Convert bash associative array to JSON object

Each value in an associative array must be preceded by an attribute tag. Then it can be serialized into a JSON object.

## Convert bash array to JSON array

Each value in the array must be preceded by an attribute tag. Then it can be serialized into a JSON array.


