
#!/bin/bash

# Red Hat Enterprise Linux Hardware Certification Test Environment Setup Script
# Run this script after RHEL boot on both the SUT and HUT

# Prerequisites for both SUT and HUT:
# 1) Boot the Server being used to run the certification with the GA ISO of the RHEL version to be certified on. During system setup, do the following:
#    a) Set up an admin account with an easy password
#         - recommended: Use the same password for all accounts on the SUT and 
#           HUT
#         - Allow admin login through SSH (If there is a checkbox for this)
#         - Ensure kdump is enabled (If there is a setting for this, yes by default)
#    b) Set up a user account 
#    c) Ensure The network is connected
#    d) register the system under a Red Hat admin account 
#	  - Do this while configuring the system  
#    e) set the system software to workstation
# 2) Ensure the Date and Time is set correctly in settings
# 3) Ensure the system network connection is enabled in settings


# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]
then 
  echo "Please run as root (sudo su)."

else

  # Create keyboard shortcut for Terminal
  ID=`id -u $USERNAME`
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'terminal' 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 2> /dev/null


  # Set proxy to automatic
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


  # Disable automatic DNS
  NIC=`nmcli -t -f DEVICE c s -a | grep -v 'lo' | grep -v 'wl'`
  nmcli connection modify $NIC ipv4.ignore-auto-dns 'yes'


  # Disable auto suspend/dim screen/screen blank/auto power-saver
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


  # Ensure Internet is connected
  nslookup "hp.com" > /dev/null
  if [ $? != 0 ]
  then 
    echo "No Internet connection! Please check your network" && sleep 5 && exit 0
  fi


  # Get RHEL version from user
  echo "What RHEL version are you certifying? (8/9)"
  read -p "RHEL version: " VERSION
  while [[ $VERSION != [89] ]] 
  do 
    echo "Please enter a valid RHEL version number (8/9)"
    read -p "RHEL version: " VERSION
  done
    

  # Get system type from user
  echo "Are you setting up a client or server ?"
  read -p "(c)Client  (s)Server: " TYPE
  while [[ "$TYPE" != [CcSs] ]]
  do 
    echo "Please enter a valid response (C or S)"
    read -p "(c)Client  (s)Server: " TYPE
  done


  # Attach the Red Hat Enterprise Linux Self-Serve Subscription
  echo
  echo "--------------------------------------"
  echo "ATTACHING CORRECT RHEL SUBSCRIPTION..."
  echo "--------------------------------------"
  echo
  # Get Pool ID
  POOL_ID=`subscription-manager list --available | sed -n '{/500 Nodes/, /Subscription Name/ p}' | head -n -1 | grep "Pool ID:" | rev | cut -d ' ' -f1 | rev`
  subscription-manager attach --pool=$POOL_ID

  if [ $VERSION == "8" ]
  then
    subscription-manager repos --enable=cert-1-for-rhel-8-x86_64-rpms || ( echo "Attaching certification repo failed, please runs script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-rpms || ( echo "Attaching baseos repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-appstream-rpms || ( echo "Attaching appstream failed, please run script again."; exit $ERRCODE )
  else
    subscription-manager repos --enable=cert-1-for-rhel-9-x86_64-rpms || ( echo "Attaching certification repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-baseos-rpms || ( echo "Attaching baseos repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-appstream-rpms || ( echo "Attaching appstream repo failed, please run script again."; exit $ERRCODE )
  fi


  # Install the certification software on Clinet & Server
  subscription-manager attach --auto
  echo
  echo "------------------------------------"
  echo "INSTALLING CERTIFICATION SOFTWARE..."
  echo "------------------------------------"
  echo
  yum install -y redhat-certification-hardware || ( echo "Installing hardware test suite package failed!" )

  # Install the Cockpit on Server only
  if [[ "$TYPE" == [Ss] ]]
  then
    echo
    echo "-----------------------------------"
    echo "INSTALLING COCKPIT RPM ON SERVER..."
    echo "-----------------------------------"
    echo
    yum install -y redhat-certification-cockpit || ( echo "Installing Cockpit RPM failed!" )
  fi


  # Install GA kernel 
  echo
  echo "---------------------------------"
  echo "ENSURING PROPER KERNEL VERSION..."
  echo "---------------------------------"
  echo
  KERNEL=$(uname -r)
  case $VERSION in
    "8")
      if [ "$KERNEL" != "4.18.0-477.10.1.el8_8.x86_64" ];
      then 
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-4.18.0-477.10.1.el8_8 kernel-debug-4.18.0-477.10.1.el8_8 kernel-debuginfo-4.18.0-477.10.1.el8_8 --skip-broken
      fi
      ;;
    "9")
      if [ "$KERNEL" != "5.14.0-284.11.1.el9_2.x86_64" ];
      then 
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-5.14.0-284.11.1.el9_2 kernel-debug-5.14.0-284.11.1.el9_2 kernel-debuginfo-5.14.0-284.11.1.el9_2 --skip-broken
      fi
      ;;
  esac


  # Enable the cockpit.socket on Server
  if [[ "$TYPE" == [Ss] ]]
  then
    echo
    echo "--------------------------"
    echo "ENABLING COCKPIT SOCKET..."
    echo "--------------------------"
    echo
    systemctl enable --now cockpit.socket || ( echo "Enabling cockpit socket failed" )
    systemctl start cockpit || ( echo "Starting Cockpit failed" )

  # Disable close lid suspend on Server
  sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf && systemctl restart systemd-logind.service
  fi

  
  echo
  echo "----------------------------------"
  echo "RHEL CERTIFICATION SETUP COMPLETE"
  echo "----------------------------------"
  echo
  reboot now

fi

exit

