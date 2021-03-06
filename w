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
    rm files_to_ignore
    find $1/bin $1/.gitignore $1/.git > files_to_ignore
    if hash inotifywait 2>/dev/null; then
        inotifywait -r -m $1 -e create -e moved_to -e modify -e delete --fromfile files_to_ignore --exclude $1/.git/index.lock --exclude $1/.git/index | while read path action file; do
            echo "File '$file' in directory '$path' via '$action'"
        done
    else
        apt install inotify-tools -y
        inotifywait -r -m $1 -e create -e moved_to -e modify -e delete --fromfile files_to_ignore --exclude $1/.git/index.lock --exclude $1/.git/index | while read path action file; do
            echo "File '$file' in directory '$path' via '$action'"
        done
    fi
elif [ "$machine" = "Mac" ]; then
    if hash fswatch 2>/dev/null; then
        fswatch -r -x --event Created --event MovedTo --event Updated --event Removed --exclude .git --exclude bin $1 | while read path action file; do
            echo "$path $action"
        done
    else
        brew install fswatch
        fswatch -r -x --event Created --event MovedTo --event Updated --event Removed --exclude .git --exclude bin $1 | while read path action file; do
            echo "$path $action"
        done
    fi

fi
