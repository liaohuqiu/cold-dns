#!/bin/bash

set -e

prj_path=$(cd $(dirname $0); pwd -P)
SCRIPTFILE=`basename $0`

devops_prj_path="$prj_path/devops"

base_do_init=0
source $devops_prj_path/base.sh

app_image=andyshinn/dnsmasq:2.76
app_container="cold-dns"

function stop() {
    stop_container $app_container
}

function run() {
    if [ "$(container_is_running $app_container)" == "true" ]; then
        return
    fi
    local cmd=$1
    local args="--restart=always"
    args="$args --cap-add=NET_ADMIN"
    args="$args -p 53:53/tcp -p 53:53/udp"
    run_cmd "docker run -d $args --name $app_container $app_image $cmd"
}

function restart() {
    stop
    run
}

function help() {
	cat <<-EOF
    
    Usage: mamanger.sh [options]

	    Valid options are:

            run
            stop
            restart

            -h                      show this help message and exit

EOF
}

ALL_COMMANDS=""
ALL_COMMANDS="$ALL_COMMANDS run stop restart"
list_contains ALL_COMMANDS "$action" || action=help
$action "$@"
