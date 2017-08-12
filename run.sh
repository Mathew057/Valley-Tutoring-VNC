#!/bin/bash

foreground=false

function daemonStop {
    {
    #Stop all C9vnc sub-processes
    supervisorctl stop novnc
    supervisorctl stop fluxbox
    supervisorctl stop x11vnc
    supervisorctl stop xvfb

    #If that fails, killall
    killall Xvfb x11vnc websockify supervisord
    }&> /dev/null
}

function finish {
    #Revert back to original
    mv ${HOME}/.fluxbox/startup.bak ${HOME}/.fluxbox/startup
    if ! $foreground; then
        daemonStop
    fi
    echo "finished cleanly"
}
trap finish SIGINT SIGTERM

command=$1

function showHelp {
    echo -e "Usage: c9vnc <args>"
    echo -e "   -h          Print this message"
    echo -e "   -f          Run in the foreground"
    echo -e "   -k          Kill running daemon"
    echo -e "No arguments will try to start daemon process"
}

function runningMessage {
    echo VNC client running at https://$C9_HOSTNAME/vnc.html?autoconnect=true
}

function foregroundStart {

    #Run C9vnc in foreground

    #Set environment variables
    export XDG_RUNTIME_DIR=/tmp/C9VNC
    export DISPLAY=:99.0

    #Back up existing configs
    cp ${HOME}/.fluxbox/startup ${HOME}/.fluxbox/startup.bak
    cp ${HOME}/.config/supervisord.conf ${HOME}/.config/supervisord.conf.bak

    echo "Running command $command on VNC"
    #Modify fluxbox config
    sed -i -e "s|somecommand|$command|g" ${HOME}/.fluxbox/startup

    #Modify supervisord.conf
    sed -i -e 's/nodaemon=false/nodaemon=true/' ${HOME}/.config/supervisord.conf

    #Run supervisord
    supervisord -c ${HOME}/.config/supervisord.conf
}

function daemonStart {
    echo -e "Starting c9vnc daemon"
    echo "Running command $command on VNC"
    {
    #Set environment variables
    export XDG_RUNTIME_DIR=/tmp/C9VNC
    export DISPLAY=:99.0

    #Back up existing configs
    cp ${HOME}/.fluxbox/startup ${HOME}/.fluxbox/startup.bak

    #Modify fluxbox config
    sed -i -e "s|somecommand|$command|g" ${HOME}/.fluxbox/startup

    #Run supervisord
    supervisord -c ${HOME}/.config/supervisord.conf
    }&> /dev/null
}



while getopts :hfk opt; do
    foreground=true
    case $opt in
        h) showHelp; exit ;;
        f) runningMessage; foregroundStart ; exit;;
        k) daemonStop ; exit ;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

# No arguments, default to starting in background
if ! $foreground; then
    runningMessage; daemonStart ; sleep 5 ;  exit ;
fi
