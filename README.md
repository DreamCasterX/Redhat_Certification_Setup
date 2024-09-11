## Red Hat Enterprise Linux Hardware Certification Test Environment Setup Tool

#### [Release Note]
1.	Customized for HP TDC QA team, including hotkey/disable auto-suspend/collect test log..,etc
2.	Support RHEL 8.x/9.x/10
3.	Auto update new versions from the remote repository


### Run this script after RHEL boot on both the SUT and HUT
#
#### [Prerequisites]
##### 1).  Boot to USB with GA ISO
+ Set up an admin account (Name: u  Password: u)
  +  Root account => Allow SSH login
  +  User account => Enable administrator access
  +  Ensure kdump is enabled
+ Set Software Selection to "Workstation"
+ Connect to Internet and register with Red-Hat partner account (Optional)
#####  2).  Boot to OS 
+ Assign an IP to HUT & SUT. Make sure you can ping HUT <-> SUT successfully
