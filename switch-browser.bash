#!/bin/bash

while getopts "h?cfl" opt; do
    case "$opt" in
    h | \?)
        echo "Usage: $0 [-c] [-f] [-h]"
        echo "-c for Chrome"
        echo "-f for Firefox"
        echo "-l for LibreWolf"
        echo "-h for help"
        exit 0
        ;;
    c)
        echo "Switching to Chrome"
        xdg-mime default google-chrome.desktop 'x-scheme-handler/http'
        xdg-mime default google-chrome.desktop 'x-scheme-handler/https'
        ;;
    f)
        echo "Switching to Firefox!"
        xdg-mime default firefox.desktop 'x-scheme-handler/http'
        xdg-mime default firefox.desktop 'x-scheme-handler/https'
        ;;
    l)
        echo "Switching to LibreWolf!"
        xdg-mime default librewolf.desktop 'x-scheme-handler/http'
        xdg-mime default librewolf.desktop 'x-scheme-handler/https'
        ;;
    esac
done
