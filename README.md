## Red Hat Enterprise Linux Hardware Certification Test Environment Setup Tool

#### [Release Note]
1.	Customized for HP TDC QA team, including Terminal hotkey/disable auto-suspend/collect test log..,etc
2.	Support RHEL 8.9 & 9.3
3.	Auto update new versions from the remote repository


### Run this script after RHEL boot on both the SUT and HUT
#
#### [Prerequisites]
##### 1).  Boot to USB with GA ISO
+ Set up an admin account (Name: u  Password: u)
  +  Root account => Allow SSH login
  +  User account => Enable administrator access
  +  Ensure kdump is enabled

+ Connect to Internet and register with Red-Hat partner account

+ Set Software Selection to "Workstation"

+ Set Time Zone to "Asia/Taipei"
  
#####  2).  Boot to OS 
+ Assign a static IP to HUT & SUT. Make sure you can ping HUT <-> SUT successfully
