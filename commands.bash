#!/usr/bin/env bash

read nick chan cmd args

store=$(cat ./database)
case $cmd in
    "!add") store="$store $args" ; echo "PRIVMSG $chan :stored!" ;;
    "!list") echo "PRIVMSG $chan :$store" ;;
    "!clear") store="" ; echo "PRIVMSG $chan :cleared!" ;;
esac

echo $store > ./database
