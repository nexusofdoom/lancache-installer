#!/bin/bash
#to add to build nginx 
mkdir temp-nginx
cd temp-nginx
curl http://nginx.org/download/nginx-1.13.9.tar.gz | tar zx
cd nginx-1.13.9
#Get Nginx Cache Purge from Frickle Labs:
curl "http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz" | tar zx

#Get the Range Cache Plugin from Multiplay Github
git clone https://github.com/multiplay/nginx-range-cache/ $PWD/nginx-range-cache

#Get Wandenberg NGINX Stream Module
curl "https://codeload.github.com/wandenberg/nginx-push-stream-module/tar.gz/0.5.1?dummy=/wandenberg-nginx-push-stream-module-0.5.1_GH0.tar.gz" | tar zx

#Install NGINX 
Patching NGINX for Range Cache from Multiplay
#patch -p1 <$PWD/nginx-range-cache/range_filter.patch
#Configure NGINX with the previously downloaded addons
./configure --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-pcre --with-http_v2_module --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module  --add-module=$PWD/ngx_cache_purge-2.3 --add-module=$PWD/nginx-range-cache --with-http_realip_module --with-http_gzip_static_module --with-http_geoip_module=dynamic --with-file-aio --with-threads --with-ld-opt="-lrt -ljemalloc -Wl,-z,relro -Wl,-rpath,/usr/local/lib" --with-cc-opt="-m64 -march=native -g -O3 -fstack-protector-strong --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wno-deprecated-declarations" --sbin-path=/usr/local/sbin/nginx --pid-path=/var/run/nginx.pid --conf-path=/usr/local/nginx/conf/nginx.conf
make
checkinstall --pkgname=nginx --pkgversion="1.13.9-custom" --backup=no --deldoc=yes --fstrans=no --default
echo ##########################################################################
echo Please run install-sniproxy.sh
echo ##########################################################################
