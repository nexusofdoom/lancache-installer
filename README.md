# lancache-installer
 
 #Install Debian 9.4 X64 with SSH and Endable sudo
 
 #Download url for debian 
  https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.4.0-amd64-netinst.iso
 
 #You will need avaliable ip's for all the services 
 
 #Install git 
 apt-get install git

#Clone the git repo
 
 git clone -b master http://github.com/nexusofdoom/lancache-installer
 cd lancache-installer 
 chmod +x *.sh 

#Run scripts as sudo or root user

#Run 
 ./install.sh
 
#Next run
 ./install-jemalloc.sh

#Then run 
 ./install-nginx.sh

#After run 
 ./install-sniproxy.sh

#Last run 
 ./install-lancache.sh
