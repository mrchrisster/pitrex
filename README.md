# Setting up Pitrex Development environment under WSL #
I'm using WSL to compile Pitrex. This is what you need to do on a fresh Ubuntu (in my case 20.04) install under Windows WSL 
    
```sudo apt-get update && apt-get install make```  
```sudo apt-get install gcc-arm-none-eabi```  
  
Find [gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2](https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2?revision=c34d758a-be0c-476e-a2de-af8c6e16a8a2?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2019-q3-update)  
Download file and install:  
  
`sudo tar -xf gcc-arm-none-eabi-8-2019-q3-update-linux.tar.bz2  -C /opt`  
`printf 'export PATH=/opt/gcc-arm-none-eabi-8-2019-q3-update/bin:$PATH' >> ~/.bashrc`  
  
   






