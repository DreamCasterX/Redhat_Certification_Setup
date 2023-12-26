
#!/usr/bin/env bash


# CREATOR: mike.lu@hp.com
# CHANGE DATE: 2023/12/26
__version__=v3.8


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
#    d) Set Time Zone to "Asia/Taipei" 
# 2) Boot to OS 
#    a) Assign a static IP to HUT & SUT. Make sure you can ping HUT <-> SUT successfully


# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]
then 
 
  # Copy test result file to USB drive (Run as User)
  XmlLog=`sudo ls -t /var/rhcert/save/*xml | head -1`
  XmlLogName=`sudo ls -t /var/rhcert/save/*xml | head -1 | cut -d "/" -f5`
  USBDrive=/run/media/$USERNAME/`ls /run/media/$USERNAME`
  [[ -d /var/rhcert/save ]] && sudo cp $XmlLog $USBDrive 2> /dev/null && echo -e "💾 $XmlLogName has been captured\n"
  echo "⚠️ Please run as root (sudo su) to start the installation."

else

  # Create keyboard shortcut for Terminal
  ID=`id -u $USERNAME`
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'terminal' 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 2> /dev/null


  # Set proxy to automatic
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


  # Disable automatic DNS (Optional)
  # NIC=`nmcli -t -f DEVICE c s -a | grep -v 'lo' | grep -v 'wl' | grep -v 'virbr0'`
  # nmcli connection modify $NIC ipv4.ignore-auto-dns 'yes'


  # Disable auto suspend/dim screen/screen blank/auto power-saver
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


  # Show battery percentage
  sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface show-battery-percentage "true" 2> /dev/null


  # Ensure Internet is connected
  nslookup "hp.com" > /dev/null
  if [ $? != 0 ]
  then 
    echo "❌ No Internet connection! Please check your network" && sleep 5 && exit 0
  fi


  # Check the latest update
  release_url=https://api.github.com/repos/DreamCasterX/Redhat_Certification_Setup/releases/latest
  new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
  tarball_url="https://github.com/DreamCasterX/Redhat_Certification_Setup/archive/refs/tags/${new_version}.tar.gz"
  if [[ $new_version != $__version__ ]]
  then
    echo -e "⭐️ New version found!"
    sleep 2
    echo -e "\nDownloading update..."
    pushd "$PWD" > /dev/null 2>&1
    curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".RHELCertSetup.tar.gz" "${tarball_url}"
    if [[ -e ".RHELCertSetup.tar.gz" ]]
    then
	tar -xf .RHELCertSetup.tar.gz -C "$PWD" --strip-components 1 > /dev/null 2>&1
	rm -f .RHELCertSetup.tar.gz
	rm -f README.md
	popd > /dev/null 2>&1
	sleep 3
	chmod 777 RHELCertSetup_${new_version}.sh
	echo -e "Successfully updated! Please run the new version: RHELCertSetup_${new_version}.sh\n\n" ; exit 1
    else
	echo -e "\n❌ Error occured while downloading" ; exit 1
    fi 
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
    subscription-manager repos --enable=cert-1-for-rhel-8-x86_64-rpms || ( echo "❌ Attaching certification repo failed, please runs script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-rpms || ( echo "❌ Attaching baseos repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-appstream-rpms || ( echo "❌ Attaching appstream failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-debug-rpms || ( echo "❌ Attaching baseos debug repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-8-for-$(uname -m)-appstream-debug-rpms || ( echo "❌ Attaching appstream debug failed, please run script again."; exit $ERRCODE )
  else
    subscription-manager repos --enable=cert-1-for-rhel-9-x86_64-rpms || ( echo "❌ Attaching certification repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-baseos-rpms || ( echo "❌ Attaching baseos repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-appstream-rpms || ( echo "❌ Attaching appstream repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-baseos-debug-rpms || ( echo "❌ Attaching baseos debug repo failed, please run script again."; exit $ERRCODE )
    subscription-manager repos --enable=rhel-9-for-$(uname -m)-appstream-debug-rpms || ( echo "❌ Attaching appstream debug repo failed, please run script again."; exit $ERRCODE )
  fi


  # Install the certification software on Clinet & Server
  subscription-manager attach --auto
  echo
  echo "------------------------------------"
  echo "INSTALLING CERTIFICATION SOFTWARE..."
  echo "------------------------------------"
  echo
  yum install -y redhat-certification-hardware || ( echo "❌ Installing hardware test suite package failed!" )

  # Install the Cockpit on Server only
  if [[ "$TYPE" == [Ss] ]]
  then
    echo
    echo "-----------------------------------"
    echo "INSTALLING COCKPIT RPM ON SERVER..."
    echo "-----------------------------------"
    echo
    yum install -y redhat-certification-cockpit || ( echo "❌ Installing Cockpit RPM failed!" )
  fi


  # Install GA kernel 
  echo
  echo "---------------------------------"
  echo "ENSURING PROPER KERNEL VERSION..."
  echo "---------------------------------"
  echo
  RELEASE=$(cat /etc/redhat-release | cut -d ' ' -f6)
  KERNEL=$(uname -r)
  case $VERSION in
    "8")
      if [[ "$RELEASE" == "8.8" && "$KERNEL" != "4.18.0-477.10.1.el8_8.x86_64" ]];
      then 
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-4.18.0-477.10.1.el8_8 kernel-debug-4.18.0-477.10.1.el8_8 kernel-debuginfo-4.18.0-477.10.1.el8_8 --skip-broken
      fi
      if [[ "$RELEASE" == "8.9" && "$KERNEL" != "4.18.0-513.5.1.el8_9.x86_64" ]];
      then 
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-4.18.0-513.5.1.el8_9 kernel-debug-4.18.0-513.5.1.el8_9 kernel-debuginfo-4.18.0-513.5.1.el8_9 --skip-broken
      fi
      ;;
    "9")
      if [[ "$RELEASE" == "9.2" && "$KERNEL" != "5.14.0-284.11.1.el9_2.x86_64" ]];
      then 
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-5.14.0-284.11.1.el9_2 kernel-debug-5.14.0-284.11.1.el9_2 kernel-debuginfo-5.14.0-284.11.1.el9_2 --skip-broken
      fi
      if [[ "$RELEASE" == "9.3" && "$KERNEL" != "5.14.0-362.8.1.el9_3.x86_64" ]];
      then
        yum remove -y kernel kernel-debug kernel-debuginfo
        yum install -y kernel-5.14.0-362.8.1.el9_3 kernel-debug-5.14.0-362.8.1.el9_3 kernel-debuginfo-5.14.0-362.8.1.el9_3 --skip-broken
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
    systemctl enable --now cockpit.socket || ( echo "❌ Enabling cockpit socket failed" )
    systemctl start cockpit || ( echo "❌ Starting Cockpit failed" )

  # Disable close lid suspend on Server
  sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf && systemctl restart systemd-logind.service
  fi


  # Update system but kernel
    echo
    echo "------------------------------"
    echo "UPDATING THE LATEST PACKAGE..."
    echo "------------------------------"
    echo
    dnf update -y --exclude=kernel* || ( echo "❌ Updating system failed" && sleep 5 && exit 0 )
  
  echo
  echo "--------------------------------------"
  echo "✅ RHEL CERTIFICATION SETUP COMPLETED"
  echo "---------------------------------------"
  echo
  sleep 5
  reboot now

fi

exit

