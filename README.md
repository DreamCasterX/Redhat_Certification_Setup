## Red Hat Enterprise Linux Hardware Certification Test Environment Setup Tool

### Run this script after RHEL boot on both the SUT and HUT

### Prerequisites:
##### 1.  Boot to USB with GA ISO
> a) Set up an admin account (Name: u  Password: u)
>>  - Root account => Allow SSH login
>>  - User account => Enable administrator access
>>  - Ensure kdump is enabled

> b) Connect to Internet and register with Red-Hat partner account

> c) Set Software Selection to "Workstation"

> d) Set Time Zone to "Asia/Taipei" 
#####  2.  Boot to OS 
> a) Assign a static IP to HUT & SUT. Make sure you can ping HUT <-> SUT successfully
