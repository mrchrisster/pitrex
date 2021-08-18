# Setting up Pitrex Development environment under WSL #
  
Malban works with a VM image to compile Pitrex. You can watch his setup tutorial [here](http://vide.malban.de/pitrex/pitrex-baremetal-quick-start-unfinished)  
  
Since I work with Windows, I use WSL.  
This is what you need to do on a fresh Ubuntu (in my case 20.04) install under Windows WSL 
    
```sudo apt-get update && apt-get install make```  
```sudo apt-get install gcc-arm-none-eabi```  
  
Find [gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2](https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2?revision=c34d758a-be0c-476e-a2de-af8c6e16a8a2?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2019-q3-update)  
Download file and install:  
  
`sudo tar -xf gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2  -C /opt`  
`printf 'export PATH=/opt/gcc-arm-none-eabi-8-2019-q3-update/bin:$PATH' >> ~/.bashrc`  
`source ~/.bashrc`  
  
You should now be able to compile some Pitrex code. Quick test:  
  
`cd ~/Pitrex/pitrex/loader`  
`make -f Makefile`  
  
**MAKE SURE YOU DON'T USE `/mnt/c` DIR. FOR SOME REASON IT MAKES COMPILING MUCH SLOWER** 
  
You can access your dev dir from windows from `\\wsl$\Ubuntu\home`  
In `Pitrex/pitrex/loader/Makefile` I have it set up that it automatically copies the new version to the SD card. SD cards don't get auto-mounted in WSL so I do it everytime I run Makefile. If you wish to change the drive letter, update these lines:  
`	sudo mount -t drvfs f: /mnt/f  
	cp loader.pit /mnt/f`
   






