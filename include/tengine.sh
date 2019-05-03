

tengine_preinstall_settings(){
    # display_menu tengine last
    # if [ "${apache}" == "do_not_install" ]; then
    #     apache_modules_install="do_not_install"
    # else
    #     display_menu_multi apache_modules last
    # fi
    apache_modules_install="do_not_install"
    pass

}

install_tengine(){
    tengine_configure_args="--prefix=${tengine_location} \
    --user=www \
    --group=www \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_concat_module \
    --with-pcre"
   

    log "Info" "Starting to install dependencies packages for tengine..."
    # local apt_list=(zlib1g-dev openssl libssl-dev libxml2-dev lynx lua-expat-dev libjansson-dev)
    local yum_list=(pcre-devel openssl openssl-devel)
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
    fi
    log "Info" "Install dependencies packages for tengine completed..."

    cd ${cur_dir}/software/
    download_file "${tengine2_2_filename}.tar.gz" "${tengine2_2_filename_url}"
    tar zxf ${tengine2_2_filename}.tar.gz
    cd ${tengine2_2_filename}
    
    error_detect "./configure ${tengine_configure_args}"

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
    log "Info" "finish tengine install begin set config file"
    
    config_tengine 
}

config_tengine(){
    id -u www >/dev/null 2>&1
    [ $? -ne 0 ] && groupadd www && useradd -M -s /sbin/nologin -g www www
    [ ! -d "${web_root_dir}" ] && mkdir -p ${web_root_dir} && chmod -R 755 ${web_root_dir}

    ln -s ${tengine_location}/logs /var/log/nginx
    mkdir -p /var/log/nginx/logs/access/
    # chmod 775 /alidata/server/tengine/logs
    chmod 755 /var/log/nginx/logs
    # chown -R www:www /alidata/server/tengine/logs
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

    # cp -f ${cur_dir}/init.d/nginx-init /etc/init.d/nginx
    # chmod 755 /etc/init.d/nginx
    # chkconfig --add nginx

}






