#!/usr/bin/env bash

set -e

test -f /etc/profile.d/rvm.sh && . /etc/profile.d/rvm.sh
test -f $HOME/.rvm/scripts/scripts/rvm && $HOME/.rvm/scripts/scripts/rvm

#HOME=/root

param=$1

__FILE__=$(readlink -f $0)

apphome=$(dirname $__FILE__)

logfile=$apphome/logs/app.log
pid=$apphome/rack.pid

host="0.0.0.0"
port="4567"


test -e $(dirname $logfile) || mkdir $(dirname $logfile)
test -e $apphome/upload || mkdir $apphome/upload

case $param in
    start)
        echo -en "\nStart Rising-tide ... "
        if [[ ! -f $pid ]]
        then
            cd $apphome && (nohup rackup -o $host -p $port -P $pid &> $logfile &)
            sleep 5

            if [[ -f $pid ]]
            then
                echo -e "[ \e[32mOK\e[0m ] \n"
                #echo -e "[ \e[32mOK\e[0m ]  pid: $(<$pid) \n"
            else
                echo -e "\e[31m Start app invoked error, trace log showed below:\e[0m \n"
                cat $logfile
            fi
        else
            echo -e "\e[31m App already running, pid: $(<$pid). 
            Unless remove \"$pid\" file and start it again, please. \e[0m \n"
            exit
        fi
        ;;
    stop)
        echo -en "\nStop Rising-tide ... "
        if [[ -f $pid ]]
        then
            kill -9 $(<$pid) && echo -e "[ \e[32mOK\e[0m ] \n"
            rm $pid
        else
            echo -e "\e[31mApp not running, at least pid file empty.\e[0m \n"
            exit
        fi
        ;;
    status)
        echo ""
        ps -ef |grep $apphome |grep -v "grep" |grep -v "vim"
        echo ""
        ;;
    restart)
        $__FILE__ stop
        sleep 1
        $__FILE__ start
        ;;
    *)
        echo -e "\n PARAMS: start | stop | restart | status \n"
        ;;
esac


