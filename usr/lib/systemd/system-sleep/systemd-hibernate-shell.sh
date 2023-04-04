#!/bin/bash

case $1 in
    pre)
        sync
        (
            echo 3 > /proc/sys/vm/drop_caches
        ) &
        wait
        echo "'echo 3 > /proc/sys/vm/drop_caches' is finished"
    ;;
    post)
        sysctl -w vm.swappiness=1
    ;;
esac
