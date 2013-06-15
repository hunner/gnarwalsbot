#!/usr/bin/env bash

function send {
    echo "-> $1"
    echo "$1" >> .botfile
}
rm .botfile
mkfifo .botfile
tail -f .botfile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true ; do
    if [[ -z $started ]] ; then
        send "USER bdbot bdbot bdbot :bdbot"
        send "NICK hhbot"
        send "JOIN #notgnarwals"
        started="yes"
    fi
    read irc
    echo "<- $irc"
    if `echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null` ; then
        send "PONG"
    elif `echo $irc | grep PRIVMSG > /dev/null` ; then
        chan=`echo $irc | cut -d ' ' -f 3`
        barf=`echo $irc | cut -d ' ' -f 1-3`
        saying=`echo ${irc##$barf :}|tr -d "\r\n"`
        nick="${irc%%!*}"; nick="${nick#:}"
        cmd=`echo $saying | cut -d ' ' -f 1`
        args="${saying#$cmd }"
        if [[ $cmd == 'quit' && $nick == 'Hunner' ]] ; then
            send "QUIT :bai"
        fi
        #:benzer!~brianb@stargate.cat.pdx.edu PRIVMSG #notgnarwals :!cmd arg1 arg2
        var=$(echo $nick $chan $cmd $args | ./commands.bash)
        if [[ ! -z $var ]] ; then
            send "$var"
        fi
    fi
done
