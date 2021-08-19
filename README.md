# What is Pitrex #  
  
The PiTrex cartridge connects a Raspberry Pi Zero with a Vectrex. It is a cartridge that allows to run programs and games on the Raspberry Pi which can use the Vectrex as a vector monitor and use the vectrex controller as the input device.  
  
You can find more info and order the cartridge [here](http://www.ombertech.com/pitrex.php)  
  
# Disclaimer #  
  
The code and release is based on Malban's June 15, 2021 release. All code hosted here is written by [Malban](http://vide.malban.de) (and some other people like [Kevin Koster](http://www.ombertech.com/contact.htm)). I just did slight modifications to the code. You can find more info (and possibly more up to date versions) [here](http://vide.malban.de/pitrex/pitrex-baremetal-download)   
Since I'm just modifying existing code, please don't expect new emulator features from me :)  
  
# Pitrex Menu #  
  
My main motivation was customizing the Menu system for Pitrex, adding new logos and changing the menu structure to my liking.  
My code changes can therefore be found in `pitrex/loader` directory.
To change the menu structure, please look at `loaderMain.c` and the icons can be found in `icons.i`  
   
# Current Changelog #  
  
  - Added a menu to randomly launch a Vectrex Game  
  - Added Demo File Selection Menu  
  - Added Star Wars (AAE) menu  
  - Changed layout of Menu  
  - Omitted Music Player, Video Player and Vectrex Speedy  
   
# Setting up Pitrex Development environment under WSL #
  
Malban works with a VM image to compile Pitrex. You can watch his setup tutorial [here](http://vide.malban.de/pitrex/pitrex-baremetal-quick-start-unfinished) if you prefer to use a VM image.  
 
Since I work in Windows I found it more convenient to compile through WSL. Here's how to set up the compiler on a fresh Ubuntu (in my case 20.04) install under Windows WSL 
    
```sudo apt-get update && apt-get install make```  
```sudo apt-get install gcc-arm-none-eabi```  
  
Find [gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2](https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2?revision=c34d758a-be0c-476e-a2de-af8c6e16a8a2?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2019-q3-update)  
Download file and install:  
  
`sudo tar -xf gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2  -C /opt`  
`printf 'export PATH=/opt/gcc-arm-none-eabi-8-2019-q3-update/bin:$PATH' >> ~/.bashrc`  
`source ~/.bashrc`  
  
You should now be able to compile some Pitrex code. Quick test:  
  
`cd ~/pitrex/pitrex/loader`  
`make -f Makefile`  
  
**MAKE SURE YOU DON'T USE `/mnt/c` DIR. FOR SOME REASON IT MAKES COMPILING MUCH SLOWER** 
  
You can access your dev dir from windows from `\\wsl$\Ubuntu\home`  
In `pitrex/loader/Makefile` I have it set up that it automatically copies the new version to the SD card. SD cards don't get auto-mounted in WSL so it mounts the SD to Ubuntu everytime you run Makefile. If you wish to change the drive letter, update these lines in `/pitrex/loader/Makefile`:  
  
`sudo mount -t drvfs f: /mnt/f`   
`cp loader.pit /mnt/f`  
  
You also need to initially create `/mnt/f`
   
# Working with Vecci #
  
In order to edit the icons, you need to install the most recent versions of [Vide](http://vide.malban.de/download/download-history). Then go to `Vide.w64\Vide.app\app` and replace `Vide.jar` with the one from [here](https://github.com/mrchrisster/pitrex/blob/main/Vide/Vide.jar)  
  
Now you can import icons to edit from `pitrex/loader/icons.i`  

![step1](https://github.com/mrchrisster/pitrex/blob/main/images/icons_imp1.png)
  
Delete vector count:  
  
![step2.1](https://github.com/mrchrisster/pitrex/blob/main/images/icons_imp2.1.png)


Change line 1 and line x as follows:  


![step2](https://github.com/mrchrisster/pitrex/blob/main/images/icons_imp2.jpg)
  
  
Et voila! You can now edit the vectors by pushing the middle mouse button to switch between moving points or whole lines - or draw new lines.  
Once you are done, go to the export tab and go to `absolut list (start + end)` and hit the C button in the upper right corner. You can now paste this code into icons.i, change the name and use it for your new menu item.  
  
![step4](https://github.com/mrchrisster/pitrex/blob/main/images/icons_imp4.png)


