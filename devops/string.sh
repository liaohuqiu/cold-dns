#!/bin/bash
function change_line() {
    local mode=$1
    local file=$2
    local tag_str=$3
    local content=$4
    local file_bak=$file".bak"
    local file_temp=$file".temp"
    cp -f $file $file_bak
    if [ $mode == "append" ]; then
        grep -q "$tag_str" $file || echo "$tag_str" >> $file
    else
        cat $file |awk -v mode="$mode" -v tag_str="$tag_str" -v content="$content" '
        {
            if ( index($0, tag_str) > 0) {
                if ( mode == "after"){
                    printf( "%s\n%s\n", $0, content);

                } else if (mode == "before")
                {
                    printf( "%s\n%s\n", content, $0);

                } else if(mode == "replace") 
                {
                    print content;
                }
            } else if ( index ($0, content) > 0) 
            {
                # target content in line
                # do nothing
            } else
            {
                print $0;
            }
        }' > $file_temp
        mv $file_temp $file
    fi
}

function str_contains() {
    local str="$1"
    local substr="$2"
    if [[ "$str" == *"$substr"* ]]; then
        echo 1
    else
        echo 0
    fi
}

function diff_from_1() {
    if [[ ! -z "$1" && ! -z "$2" ]];  then
        local ret=''
        for item in $1
        do
            if [ $(str_contains "$2" "$item") == 0 ]; then
                ret="$ret $item"
            fi
        done
        echo $ret
    else
        echo $1
    fi
}
