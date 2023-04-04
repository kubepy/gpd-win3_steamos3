#!/bin/bash

case $1 in
    pre)
        #sysctl -w vm.swappiness=1
    ;;
    post)
        sysctl -w vm.swappiness=1
    ;;
esac
