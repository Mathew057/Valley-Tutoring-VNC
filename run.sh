#!/bin/bash
remotecommand="xterm -e $command"

echo VNC client running at https://$C9_HOSTNAME/vnc.html?autoconnect=true

#Set environment variables
export XDG_RUNTIME_DIR=/tmp/C9VNC
export DISPLAY=:99.0

#Back up existing configs
cp ${HOME}/.config/supervisord.conf ${HOME}/.config/supervisord.conf.bak

echo "Running command $remotecommand on VNC"

#Modify supervisord.conf
sed -i -e "s|command=somecommand|command=$remotecommand|g" ${HOME}/.config/supervisord.conf

#Run supervisord as forground in a child process that way it will actual run until we stop it
supervisord -c ${HOME}/.config/supervisord.conf > ${HOME}/.config/supervisord.log &

#allow supervisord to read the file before we remove the file
sleep 1


echo "Restoring defualts"
mv ${HOME}/.config/supervisord.conf.bak ${HOME}/.config/supervisord.conf

#run until we stop the program or supervisord exits
wait $!
