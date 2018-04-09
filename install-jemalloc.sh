#get jemalloc and build
mkdir temp-jemalloc
cd temp-jemalloc
git clone -b stable-4 --depth 1 https://github.com/jemalloc/jemalloc.git
cd jemalloc
./autogen.sh
make && make dist
checkinstall --pkgname=jemalloc --pkgversion="4-stable" --backup=no --deldoc=yes --fstrans=no --default
make clean && make distclean
echo ##########################################################################
echo Please run install-nginx.sh
echo ##########################################################################
