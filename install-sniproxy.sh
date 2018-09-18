 git clone https://github.com/dlundquist/sniproxy
 curl https://raw.githubusercontent.com/OpenSourceLAN/origin-docker/master/sniproxy/sniproxy.conf -o /etc/sniproxy.conf
 cd sniproxy
 ./autogen.sh && ./configure
 make
 checkinstall --pkgname=sniproxy --backup=no --deldoc=yes --fstrans=no --default
 make clean && make distclean
