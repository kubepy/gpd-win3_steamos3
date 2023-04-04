#!/bin/bash

case $1 in
    pre)
        (
            echo 1 > /proc/sys/vm/drop_caches
        ) &
        wait
        echo "'echo 1 > /proc/sys/vm/drop_caches' is finished"
    ;;
    post)
        sysctl -w vm.swappiness=1
    ;;
esac
