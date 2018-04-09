##ref https://github.com/dlundquist/sniproxy
mkdir temp-sniproxy
cd temp-sniproxy
git clone https://github.com/dlundquist/sniproxy
cd sniproxy/
./autogen.sh && dpkg-buildpackage
#the file name might be something like sniproxy_x64_5335253.deb it would be up one directory.
dpkg -i ../*.deb
curl https://raw.githubusercontent.com/OpenSourceLAN/origin-docker/master/sniproxy/sniproxy.conf -o /etc/sniproxy.conf
echo ##########################################################################
echo Please run install-lancache.sh
echo ##########################################################################
