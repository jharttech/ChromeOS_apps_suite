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

sleep 3

########################################################################
########################################################################
#inkscapte installation and configuration

#Install inkscape
echo "
Now going to install and configure inkscape."
sudo apt install inkscape*

#Verify the desktop shortcut was created.
if [[ -f /usr/share/applications/org.inkscape.Inkscape.desktop ]]; then
	echo "App and icon shortcut for inkscape was created successfully."
else
	echo "Error, the inkscape app and icon shortcut was not created successfully.  Exiting now!!"
	exit 1
fi

#Create the needed default svg file for mapping inkscapes default open, save, and export directory.
tee ~/workspace/.default.svg << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   width="210mm"
   height="297mm"
   viewBox="0 0 210 297"
   inkscape:export-filename="~/workspace/"
   inkscape:save-filename="~/workspace/">
  <defs />
  <g inkscape:label="Layer 1" inkscape:groupmode="layer" id="layer1" />
</svg>
EOF

sleep 3

########################################################################
########################################################################
#darktable installation and configuration

#Install darktable.
echo "
Now going to install darktable."
sudo apt install darktable

#Verify the desktop shortcut 
if [[ -f /usr/share/applications/org.darktable.darktable.desktop ]]; then
	sudo cp /usr/share/applications/org.darktable.darktable.desktop /usr/share/applications/org.darktable.darktable.desktop_old
	#Replace Exec line to open the darktable program with desired default open, save, export directory
	sudo sed -i '/Exec/ s#=/usr/bin/darktable %U#=/usr/bin/darktable --datadir ~/workspace#' /usr/share/applications/org.darktable.darktable.desktop
	_darktable_line=$(cat /usr/share/applications/org.darktable.darktable.desktop | grep datadir)
	if [[ $_darktable_line == "Exec=/usr/bin/darktable --datadir ~/workspace" ]]; then
		echo "All complete installing darktable. Use the ChromeOS app drawer to find and run darktable."
	else
		echo "Error writing darktable desktop file.  Contact your Technology Administrator. Exiting now!!"
		exit 1
	fi
else
	echo "App icon and shortcut for darktable was not created! Exiting now!!"
	exit 1
fi

sleep 3

########################################################################
########################################################################
#kdenlive installation and configuration
echo "
Now going to install and setup kdenlive."
#Install kdenlive appimage
if [[ ! -f ~/kdenlive-24.02.2-x86_64.AppImage ]]; then
	wget https://download.kde.org/stable/kdenlive/24.02/linux/kdenlive-24.02.2-x86_64.AppImage
fi

#Extract appimage to get the needed desktop file
mkdir ~/workspace/Videos
mkdir ~/temp
cp kdenlive-24.02.2-x86_64.AppImage ~/temp/kdenlive-24.02.2-x86_64.AppImage
cd ~/temp
sudo chmod +x kdenlive-24.02.2-x86_64.AppImage
sudo ./kdenlive-24.02.2-x86_64.AppImage --appimage-extract
cd

#Create the needed desktop file
sudo cp ~/temp/squashfs-root/org.kde.kdenlive.desktop /usr/share/applications/
if [[ -f /usr/share/applications/org.kde.kdenlive.desktop ]]; then
	#Replace Exec line to open the kdenlive program with desired default open, save, export directory
	sudo sed -i '/Exec/ s#=kdenlive %F#=/usr/bin/kdenlive-24.02.2-x86_64.AppImage#' /usr/share/applications/org.kde.kdenlive.desktop
	_kdenlive_line=$(cat /usr/share/applications/org.kde.kdenlive.desktop | grep /usr/bin/)
	if [[ $_kdenlive_line == "Exec=/usr/bin/kdenlive-24.02.2-x86_64.AppImage" ]]; then
		echo "All complete installing kdenlive.  Use the ChromeOS app drawer to find and run kdenlive."
	else
		echo "Error writing kdenlive desktop file. Contact your Technology Administrator. Exiting now!"
		exit 1
	fi
else
	echo "App icon and shortcut for kdenlive was not created! Exiting now!!"
	exit 1
fi

#Remove temporary files
sudo rm -rf ~/temp

#Move kdenlive appimage to /usr/bin
sudo mv kdenlive-24.02.2-x86_64.AppImage /usr/bin/

#Make kdenlive executable
sudo chmod +x /usr/bin/kdenlive-24.02.2-x86_64.AppImage

#Create rc file for desired kdenlive default locations.
tee ~/.config/kdenlive-appimagerc << EOF
[MainWindow]
ToolBarsMovable=Disabled

[Media Browser]
Allow Expansion=false
Decoration position=2
Show hidden files=false
Sort by=Name
Sort directories first=true
Sort hidden files last=false
Sort reversed=false
View Style=DetailTree

[OnlineResources]
provider=Freesound
zoom=7

[Recent Dirs]
KdenliveClipFolder[$e]=$HOME/workspace/Videos/

[Scope_Histogram]
autoRefresh=true
bEnabled=true
gEnabled=true
logScale=false
rEnabled=true
realtime=false
rec601=false
sEnabled=false
yEnabled=true

[Scope_RGB Parade]
autoRefresh=true
axis=false
gradref=false
paintmode=0
realtime=false

[Scope_Vectorscope]
75PBox=false
autoRefresh=true
axis=false
backgroundmode=0
colorspace_ypbpr=false
gain=1
iqlines=false
paintmode=0
realtime=false

[Scope_Waveform]
autoRefresh=true
paintmode=0
realtime=false
rec601=false

[UiSettings]
ColorSchemePath=BreezeDark.colors

[bin]
treeviewheaders=AAAA/wAAAAAAAAABAAAAAAAAAAABAAAAAAAAAAAAAAAJ/gEAAAAIAAAABgAAACgAAAADAAAAOAAAAAcAAAAwAAAAAQAAADgAAAAIAAAAZAAAAAIAAABgAAAABQAAAFEAAAAEAAAAMAAAAGIAAAAJAQEAAQAAAAAAAAAAAAAAAGT/////AAAAgQAAAAAAAAAJAAAAYgAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAD6AAAAAA/AAAAAA==

[capture]
decklink_extension=mov
decklink_parameters=vcodec=dnxhd vb=145000k acodec=pcm_s16le threads=%threads
grab_extension=mov
grab_parameters=-crf 25 -vcodec libx264 -preset veryfast -threads 0
v4l_extension=mpg
v4l_parameters=qscale=4 ab=192k vcodec=mpeg2video acodec=mp2 threads=%threads

[env]
defaultimageapp=/usr/bin/gimp
defaultprojectfolder[$e]=$HOME/workspace/Videos
ffmpegpath[$e]=/tmp/.mount_kdenlih9rphx/usr/bin/ffmpeg
ffplaypath[$e]=/tmp/.mount_kdenlih9rphx/usr/bin/ffplay
ffprobepath[$e]=/tmp/.mount_kdenlih9rphx/usr/bin/ffprobe
kdenliverendererpath[$e]=/tmp/.mount_kdenlizPLe3G/usr/bin/kdenlive_render
lastCacheCheck=2024,5,13,14,40,42.309
meltpath[$e]=/tmp/.mount_kdenlih9rphx/usr/bin/melt
mltpath[$e]=/tmp/.mount_kdenlih9rphx/usr/share/mlt-7/profiles/

[timeline]
trackheight=69

[unmanaged]
consumerslist=avformat,multi,null,decklink,xgl,blipflash,cbrts,qglsl,rtaudio,sdl2,sdl2_audio,xml
default_profile=atsc_1080p_2997
force_breeze=true
guidesCategories=Category 1:0:#9b59b6,Category 2:1:#3daee9,Category 3:2:#1abc9c,Category 4:3:#1cdc9a,Category 5:4:#c9ce3b,Category 6:5:#fdbc4b,Category 7:6:#f39c1f,Category 8:7:#f47750,Category 9:8:#da4453
monitor_audio=false
producerslist=avformat,avformat-novalidate,abnormal,blank,color,colour,consumer,hold,loader,loader-nogl,melt,melt_file,noise,timewarp,tone,decklink,frei0r.ising0r,frei0r.lissajous0r,frei0r.nois0r,frei0r.onecol0r,frei0r.partik0l,frei0r.plasma,frei0r.test_pat_B,frei0r.test_pat_C,frei0r.test_pat_G,frei0r.test_pat_I,frei0r.test_pat_L,frei0r.test_pat_R,glaxnimate,ladspa.1221,ladspa.1849,ladspa.1069,ladspa.1086,ladspa.1222,ladspa.1226,ladspa.1844,ladspa.1841,ladspa.1843,ladspa.1066,ladspa.1223,framebuffer,blipflash,count,pgm,qimage,qtext,kdenlivetitle,vorbis,xml,xml-string,xml-nogl
project_fps=29.97002997002997
use_dark_breeze=true
widgetstyle=Default

[version]
version=24.02.2
EOF

if [[ -f ~/.config/kdenlive-appimagerc]]; then
	echo "All complete installing kdenlive.  Use the ChromeOS app drawer to find and run kdenlive."
else
	echo "kdenlive is installed but not correctly configured.  Please contact your Technology Administrator!!"

sleep 3

########################################################################
########################################################################
#Wrap up script

clear

#Message to terminal for user
echo "The following has been successfully installed:
notepad++
gimp (Replacement for Photoshop)
inkscape (Replacement for Illustrator)
darktable (Replacement for Lightroom)
kdenlive (Video Editor)

You can find all of these in the ChromeOS app drawer under the linux apps category. Thank you!!"

sleep 5

#kill -9 $PPID