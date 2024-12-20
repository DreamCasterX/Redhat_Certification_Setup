#!/usr/bin/env bash


# CREATOR: Mike Lu
# CHANGE DATE: 2024/12/20
__version__="1.8"


# Red Hat Enterprise Linux Hardware Certification Test Environment Setup Script
# Run this script after RHEL boot on both the SUT and HUT

# Prerequisites for both SUT and HUT:
# 1) Boot to USB with GA ISO
#    a) Set up an admin account (Name: u  Password: u)
#         - Root account : Allow SSH login
#         - User account : Enable administrator access
#         - Ensure kdump is enabled
#    b) Connect to Internet and register with Red-Hat partner account 
#    c) Set Software Selection to "Workstation" 
# 2) Boot to OS 
#    a) Assign a static IP to HUT & SUT. Make sure you can ping HUT <-> SUT successfully


# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]; then 

    # Copy test result file to USB drive (Run as User)
    if [[ -d /var/rhcert/save ]]; then 
        XmlLog=`sudo ls -t /var/rhcert/save/*xml | head -1`
        XmlLogName=`sudo ls -t /var/rhcert/save/*xml | head -1 | cut -d "/" -f5`
        USBDrive=/run/media/$USERNAME/`ls /run/media/$USERNAME`
        sudo cp $XmlLog $USBDrive 2> /dev/null && echo -e "💾 $XmlLogName has been captured\n"
    fi
    echo "⚠️ Please run as root (sudo su) to start the installation."

else

    # Customize keyboard shortcut
    OS_VERSION=`cat /etc/os-release | grep ^VERSION_ID= | awk -F= '{print $2}' | cut -d '"' -f2 | cut -d '.' -f1`
    ID=`id -u $USERNAME`
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
  
    # Open Terminal (Ctrl+Alt+T)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'     
    if [[ $OS_VERSION == "10" ]]; then
        sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ptyxis'
        sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'   
    else
        sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 
    fi
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 

    # Open Current folder (Super+E)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Current folder' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus .' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<super>e' 
  
    # Open Settings (Super+I)
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Settings' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-control-center' 
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<super>i'


    # Set proxy to automatic
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


    # Disable auto suspend/dim screen/screen blank/auto power-saver
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


    # Show battery percentage
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface show-battery-percentage "true" 2> /dev/null

  
    # Set time zone and reset NTP
    timedatectl set-timezone Asia/Taipei
    timedatectl set-ntp 0 && sleep 1 && timedatectl set-ntp 1


    # Ensure Internet is connected
    nslookup "hp.com" > /dev/null
    if [ $? != 0 ]; then 
        echo "❌ No Internet connection! Please check your network" && sleep 5 && exit 0
    fi


    # Disable OCSP stapling (workaround for not being able to utilize NTP) 
    cat /var/log/rhsm/rhsm.log | grep "Clock skew detected" > /dev/null
    if [ $? == 0 ]; then 
        REPOS=$(awk '/^\[/ {gsub(/[\[\]]/, "", $0); printf("--repo %s ", $0)}'  /etc/yum.repos.d/redhat.repo)
        sudo subscription-manager repo-override --add sslverifystatus:0 $REPOS   # Revert: sudo subscription-manager repo-override --remove-all
    fi
    
  
    # Get system type from user
    echo "╭─────────────────────────────────────────────────────────╮"
    [[ $OS_VERSION == [89] ]] && echo "│    RHEL $OS_VERSION System Certification Test Environment Setup   │" || echo "│    RHEL $OS_VERSION System Certification Test Environment Setup  │"
    echo "╰─────────────────────────────────────────────────────────╯"
    echo "Are you setting up a client or server?"
    read -p "(c)Client  (s)Server: " TYPE
    while [[ "$TYPE" != [CcSs] ]]
    do 
      echo "Please enter a valid response (C or S)"
      read -p "(c)Client  (s)Server: " TYPE
    done

  
    # Check system registration status
    if rhc status | grep -w 'Not connected' > /dev/null; then
        echo
        echo "----------------------"
        echo "REGISTERING  SYSTEM..."
        echo "----------------------"
        echo
        ! rhc connect && exit 0
        subscription-manager refresh
    fi
        
    
    # Enable the Red Hat Enterprise Linux Repositories
    echo
    echo "-----------------"
    echo "ENABLING REPOS..."
    echo "-----------------"
    echo
    if [[ $OS_VERSION == "8" ]]; then
        subscription-manager repos --enable=cert-1-for-rhel-8-x86_64-rpms || ( echo "❌ Enabling certification repo failed, please runs script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-rpms || ( echo "❌ Enabling baseos repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-8-for-$(uname -m)-appstream-rpms || ( echo "❌ Enabling appstream failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-debug-rpms || ( echo "❌ Enabling baseos debug repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-8-for-$(uname -m)-appstream-debug-rpms || ( echo "❌ Enabling appstream debug failed, please run script again."; exit $ERRCODE )
    elif [[ $OS_VERSION == "9" ]]; then
        subscription-manager repos --enable=cert-1-for-rhel-9-x86_64-rpms || ( echo "❌ Enabling certification repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-9-for-$(uname -m)-baseos-rpms || ( echo "❌ Enabling baseos repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-9-for-$(uname -m)-appstream-rpms || ( echo "❌ Enabling appstream repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-9-for-$(uname -m)-baseos-debug-rpms || ( echo "❌ Enabling baseos debug repo failed, please run script again."; exit $ERRCODE )
        subscription-manager repos --enable=rhel-9-for-$(uname -m)-appstream-debug-rpms || ( echo "❌ Enabling appstream debug repo failed, please run script again."; exit $ERRCODE )
    fi


    # Install the certification software on Client & Server
    echo
    echo "------------------------------------"
    echo "INSTALLING CERTIFICATION SOFTWARE..."
    echo "------------------------------------"
    echo
    dnf install -y redhat-certification && dnf install -y redhat-certification-hardware --allowerasing || ( echo "❌ Installing hardware test suite package failed!" )

    # Install the Cockpit on Server only
    if [[ "$TYPE" == [Ss] ]]; then
        echo
        echo "-----------------------------------"
        echo "INSTALLING COCKPIT RPM ON SERVER..."
        echo "-----------------------------------"
        echo
        dnf install -y redhat-certification-cockpit || ( echo "❌ Installing Cockpit RPM failed!" )
    fi


    # Install GA kernel 
    echo
    echo "---------------------------------"
    echo "ENSURING PROPER KERNEL VERSION..."
    echo "---------------------------------"
    echo
    RELEASE=$(cat /etc/redhat-release | cut -d ' ' -f6)
    KERNEL=$(uname -r)
    case $OS_VERSION in
    "8")
	    if [[ "$RELEASE" == "8.10" && "$KERNEL" != "4.18.0-553.el8_10.x86_64" ]]; then 
            dnf remove -y kernel kernel-debug kernel-debuginfo
            dnf install -y kernel-4.18.0-553.el8_10 kernel-debug-4.18.0-553.el8_10 kernel-debuginfo-4.18.0-553.el8_10 --skip-broken
        fi
        ;;
    "9")
        if [[ "$RELEASE" == "9.4" && "$KERNEL" != "5.14.0-427.13.1.el9_4.x86_64" ]]; then
            dnf remove -y kernel kernel-debug kernel-debuginfo
            dnf install -y kernel-5.14.0-427.13.1.el9_4 kernel-debug-5.14.0-427.13.1.el9_4 kernel-debuginfo-5.14.0-427.13.1.el9_4 --skip-broken
		elif [[ "$RELEASE" == "9.5" && "$KERNEL" != "5.14.0-503.11.1.el9_5.x86_64" ]]; then
            dnf remove -y kernel kernel-debug kernel-debuginfo
            dnf install -y kernel-5.14.0-503.11.1.el9_5 kernel-debug-5.14.0-503.11.1.el9_5 kernel-debuginfo-5.14.0-503.11.1.el9_5 --skip-broken
        fi
        ;;
    esac


    # Enable the cockpit.socket on Server
    if [[ "$TYPE" == [Ss] ]]; then
        echo
        echo "--------------------------"
        echo "ENABLING COCKPIT SOCKET..."
        echo "--------------------------"
        echo
        systemctl enable --now cockpit.socket || ( echo "❌ Enabling cockpit socket failed" )
        systemctl start cockpit || ( echo "❌ Starting Cockpit failed" )

        # Disable close lid suspend on Server
        sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf && systemctl restart systemd-logind.service
    fi


    # Update system except for the kernel
    echo
    echo "------------------------------"
    echo "UPDATING THE LATEST PACKAGE..."
    echo "------------------------------"
    echo
    dnf update -y --exclude=kernel* || ( echo "❌ Updating system failed" && sleep 5 && exit 0 )
  
  
    # Disable automatic software updates
    systemctl stop packagekit
    systemctl mask packagekit
  
  
    echo
    echo "--------------------------------------"
    echo "✅ RHEL CERTIFICATION SETUP COMPLETED"
    echo "---------------------------------------"
    echo
    echo "System will automatically reboot after 8 seconds..."
    echo
    for n in {8..1}s; do printf "\r$n"; sleep 1; done
    echo
    reboot now
fi

exit

