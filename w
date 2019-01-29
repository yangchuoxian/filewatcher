#!/bin/sh
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

if [ "$machine" = "Linux" ]; then
    if hash inotifywait 2>/dev/null; then
        inotifywait -m $1 -e create -e moved_to -e modify -e delete | 
            while read path action file; do
                echo "File '$file' in directory '$path' via '$action'"
            done
    else
        apt install inotify-tools -y
        inotifywait -m $1 -e create -e moved_to -e modify -e delete | 
            while read path action file; do
                echo "File '$file' in directory '$path' via '$action'"
            done
    fi
elif [ "$machine" = "Mac" ]; then
    fswatch -r -x --event Created --event MovedTo --event Updated --event Removed --exclude .git --exclude bin $1 | while read path action file; do
        echo "$path $action"
    done
fi
