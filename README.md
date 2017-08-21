VNC
===

Running X11 in a Cloud9 workspace.

![Screen Shot](screenshot.png)

Installation
------------


Clone the repository to where you'd like (in the example I use the home folder ~)

    cd ~
    git clone https://github.com/Mathew057/Valley-Tutoring-VNC.git


Enter the repository sub-directory

    cd Valley-Tutoring-VNC/

Run the install script with privileges

    sudo ./install.sh


Running
-------

Use the custom C9 sdl runner

    Run > Run With > sdlremote

Or run the script directly from the /opt/ directory

    /opt/c9vnc/c9vnc.sh
