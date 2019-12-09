#start install zlib



nginx_preinstall_settings(){
    # display_menu apache 2
    # display_menu nginx last
    # if [ "${nginx}" == "do_not_install" ]; then
    #     apache_modules_install="do_not_install"
    # else
    #     display_menu_multi apache_modules last
    # fi
    # install_zlib
    apache_modules_install="do_not_install"
    # pass
}

install_nginx(){
    nginx_configure_args="--prefix=${nginx_location} \
    --user=www \
    --group=www \
    --with-http_stub_status_module \
    --without-http-cache \
    --with-http_ssl_module \
    --with-stream \
    --with-http_gzip_static_module"

    _info "Starting to install dependencies packages for nginx..."
    local apt_list=(zlib1g-dev openssl libssl-dev libxml2-dev lynx lua-expat-dev libjansson-dev)
    local yum_list=(pcre-devel openssl openssl-devel)
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
        # sed -i 's/-Werror//' ${cur_dir}/software/${nginx_1_11_filename}/objs/Makefile
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
    fi
    _info "Install dependencies packages for nginx completed..."

    check_installed "install_pcre" "${depends_prefix}/pcre"
    check_installed "install_openssl" "${openssl_location}"



    cd ${cur_dir}/software/
    install_zlib
    
    download_file "${nginx_1_11_filename}.tar.gz" "${nginx_1_11_filename_url}"
    tar zxf ${nginx_1_11_filename}.tar.gz
    cd ${nginx_1_11_filename}
    


    error_detect "./configure ${nginx_configure_args}"
    

    if check_sys packageManager apt; then
        # 一大盲点,编译之后才有文件
        # sed -i 's/-Werror//' ${cur_dir}/software/${nginx_1_11_filename}/objs/Makefile
        sed -i 's/-Werror//' objs/Makefile
    fi

    CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
    if [ $CPU_NUM -gt 1 ];then
        # make -j$CPU_NUM
        error_detect "make -j$CPU_NUM"        
    else
        # make
        error_detect "make"
    fi

    # error_detect "parallel_make"
    error_detect "make install"
    log "Info" "finish nginx install begin set config file"
    
    config_nginx 
}


install_pcre(){
    cd ${cur_dir}/software/
    _info "${pcre_filename} install start..."
    download_file "${pcre_filename}.tar.gz" "${pcre_filename_url}"
    tar zxf ${pcre_filename}.tar.gz
    cd ${pcre_filename}

    error_detect "./configure --prefix=${depends_prefix}/pcre"
    error_detect "parallel_make"
    error_detect "make install"
    add_to_env "${depends_prefix}/pcre"
    create_lib64_dir "${depends_prefix}/pcre"
    _info "${pcre_filename} install completed..."
}

install_openssl(){
    local openssl_version=$(openssl version -v)
    local major_version=$(echo ${openssl_version} | awk '{print $2}' | grep -oE "[0-9.]+")

    if version_lt ${major_version} 1.1.1; then
        cd ${cur_dir}/software/
        _info "${openssl_filename} install start..."
        download_file "${openssl_filename}.tar.gz" "${openssl_filename_url}"
        tar zxf ${openssl_filename}.tar.gz
        cd ${openssl_filename}

        error_detect "./config --prefix=${openssl_location} -fPIC shared zlib"
        error_detect "make"
        error_detect "make install"

        if ! grep -qE "^${openssl_location}/lib" /etc/ld.so.conf.d/*.conf; then
            echo "${openssl_location}/lib" > /etc/ld.so.conf.d/openssl.conf
        fi
        ldconfig
        _info "${openssl_filename} install completed..."
    else
        _info "OpenSSL version is greater than or equal to 1.1.1, installation skipped."
    fi
}

install_zlib(){
    _info "Starting to install zlib"

    if check_sys packageManager apt; then
        wget http://zlib.net/zlib-1.2.11.tar.gz
        tar zxvf zlib-1.2.11.tar.gz 
        cd zlib-1.2.11/
        ./configure 
        make
        make install
        cd ..
    elif check_sys packageManager yum; then
    # yum install -y fail2ban 
    pass
    fi
    _info "Install development zlib completed..."    
}

config_nginx(){
    id -u www >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd www && useradd -M -s /sbin/nologin -g www www
    [ ! -d "${web_root_dir}" ] && mkdir -p ${web_root_dir} && chmod -R 755 ${web_root_dir}

    ln -s ${nginx_location}/logs /var/log/nginx
    mkdir -p /var/log/nginx/logs/access/
    # chmod 775 /alidata/server/nginx/logs
    chmod 755 /var/log/nginx/logs
    # chown -R www:www /alidata/server/nginx/logs
    chown -R www:www /var/log/nginx/logs
    # chmod -R 775 /alidata/www
    # chown -R www:www /alidata/www
    cd ..

    # cp -fR ./nginx/config-nginx/* ${nginx_location}/conf/   # need update
    if [ -f "${nginx_location}/conf/nginx.conf" ]; then
    mv ${nginx_location}/conf/nginx.conf ${nginx_location}/conf/nginx.conf.bak
    fi
    
    cp -f ${cur_dir}/conf/nginx.conf ${nginx_location}/conf/
    
    mkdir -p ${nginx_location}/conf/vhost/
    cp -f ${cur_dir}/conf/default.conf ${nginx_location}/conf/vhost/
    
    sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' ${nginx_location}/conf/nginx.conf
    
    chmod 755 ${nginx_location}/sbin/nginx
    ln -s ${nginx_location}/sbin/nginx /usr/sbin/nginx
    chmod +x /usr/sbin/nginx


# touch nginx service file

if check_sys packageManager yum; then

cat > /usr/lib/systemd/system/nginx.service  <<EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    # nginx
# systemctl start nginx.service

chmod 644 /usr/lib/systemd/system/nginx.service
systemctl enable nginx

fi

}

