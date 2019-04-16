
# Sitecore 9.0 Update 2 Auto Install
This is a simple Powershell script to install Sitecore 9 Update 2 for standlone/Developer instance. Follow the below steps to install the Sitecore in your local machine.

# Prerequisites
- Download the Sitecore 9.0 update 2 (*rev. 180604*) from [Sitecore Download Portal](https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/90/Sitecore_Experience_Platform_90_Update2.aspx)
- Unzip the Sitecore package and you will get another three zip files as pictured below
![Sitecore 9.0 files after unzip](images/sc90-unzip.PNG)
- Unzip the *XP0 Configuration files 9.0.2 rev. 180604.zip*. This will have the json files as pictured below
![Sitecore 9.0 Configuration files](images/sc90-configuration-files.PNG)
- After the above steps are completed clone or download this branch this to your local. You will get the folder structure as below
![Folder Structure](images/Folder-Structure.PNG)
- Copy all the extractued config files from *XP0 Configuration files 9.0.2 rev. 180604* and paste it into the *Configs* folder
![Configs-Folder](images/configs-folder.PNG)
- Copy the *Sitecore 9.0.2 rev. 180604 (OnPrem)_single.scwdp.zip* and *Sitecore 9.0.2 rev. 180604 (OnPrem)_xp0xconnect.scwdp.zip* and paste it into Packages folder
![Packages-Folder](images/Packages-Folder.PNG)
- Copy the Sitecore license.xml to main folder
![license](images/license.PNG)