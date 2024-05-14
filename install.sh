########################################################################
#Notepad++ installation and configure

#Install needed apt packages
echo "Now going to install needed packages"
sleep 3
sudo apt update
sudo apt install libsquashfuse0 squashfuse fuse snapd libopengl0 -y

#Install needed snap packages
echo "Now going to install needed snap packages"
sleep 3

sudo snap install core notepad-plus-plus

#Add a workspace directory for ease of use for students.
#This also keeps notepad++ from trying to open all the files 
#in the users home directory.

if [[ ! -d ~/workspace ]]; then
	mkdir ~/workspace
	sleep 2
	tee ~/workspace/readme.txt << EOF
	Use the default save directory to save your work in Notepad++.

	In the ChromeOS 'Files' app you can find your work under the 'My Files/Linux Files/workspace' directory.

	Please copy files from that location to your Google Drive to ensure you do not lose your work should this 
	machine need repairs during the school year.  Thank you!
EOF
fi

#Verify notepad snap was installed
if [[ -f /var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus.desktop ]]; then 
	#Create a desktop icon
	sudo cp /var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus.desktop /var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus.desktop.old
	if [[ ! -f /usr/share/applications/notepad-plus-plus_notepad-plus-plus.desktop ]]; then
		sudo ln -s /var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus.desktop /usr/share/applications/
	fi
else
	echo "Notepad++ was not correctly installed.  Exiting script now!!"
	exit 1
fi

#Write needed script to set xhost access and launch notepad++
#This is needed to set the xhost without chromeOS user needing to 
#Open a terminal session each login.
#We can only use sudo this way as the linux vm in chromeOS has no root password.
if [[ ! -f /opt/launch_notepad-plus-plus.sh ]]; then
	sudo tee /opt/launch_notepad-plus-plus.sh << EOF
	#!/bin/bash

	#set xhost access
	xhost +

	#launch notepad-plus-plus snap
	Exec=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus.desktop /snap/bin/notepad-plus-plus ~/workspace/readme.txt
EOF
	sudo chmod +x /opt/launch_notepad-plus-plus.sh
fi

#Verify the desktop shortcut was created
if [[ -f /usr/share/applications/notepad-plus-plus_notepad-plus-plus.desktop ]]; then
	# replace the Exec line to point to needed script that will set the xhost access everytime the notepad++ snap is ran from the chromeOS launcher
	sudo sed -i '/Exec/ s#=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/notepad-plus-plus_notepad-plus-plus\.desktop /snap/bin/notepad-plus-plus %F#=/opt/launch_notepad-plus-plus.sh#' /usr/share/applications/notepad-plus-plus_notepad-plus-plus.desktop
	_notepad_line=$(cat /usr/share/applications/notepad-plus-plus_notepad-plus-plus.desktop | grep Exec)
	if [[ $_notepad_line == "Exec=/opt/launch_notepad-plus-plus.sh" ]]; then
		echo "All complete installing notepad++.  Use the ChromeOS app drawer to find and run notepad++"
	else
		echo "Error writing the notepad++ desktop file.  Contact your Technology Administrator.  Exiting now!"
		exit 1
	fi
else
	echo "App Icon and shortcut for notepad++ was not created!! Exiting now!"
	exit 1
fi

sleep 3

########################################################################
########################################################################
#gimp installation and configuration

#Install gimp
echo "
Now going to install and configure gimp."
sudo apt install gimp

#Create a secondary launch script for gimp due to a bug in the way the desktop files Exec line reads relative paths
if [[ ! -f /opt/launch_gimp.sh ]]; then
	sudo tee /opt/launch_gimp.sh << EOF
	#!/bin/bash
	
	#launch gimp with default save and open directory set
	/usr/bin/gimp ~/workspace
EOF
	sudo chmod +x /opt/launch_gimp.sh 
fi

#Verify the desktop shortcut was created
if [[ -f /usr/share/applications/gimp.desktop ]]; then
	sudo cp /usr/share/applications/gimp.desktop /usr/share/applications/gimp.desktop_old
	#Replace the Exec line to point to the needed script that will launch gimp with the desired default save and open directory.
	sudo sed -i '/Exec/ s#=gimp-2.10 %U#=/opt/launch_gimp.sh#' /usr/share/applications/gimp.desktop
	_gimp_line=$(cat /usr/share/applications/gimp.desktop | grep launch_gimp)
	if [[ $_gimp_line == "Exec=/opt/launch_gimp.sh" ]]; then
		echo "All complete installing gimp.  Use the ChromeOS app drawer to find and run gimp."
	else
		echo "Error writing the gimp desktop file.  Contact your Technology Administrator. Exiting now!"
		exit 1
	fi
else
	echo "App Icon and shortcut for gimp was not created!! Exiting now!"
	exit 1
fi