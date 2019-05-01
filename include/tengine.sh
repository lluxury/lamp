

tengine_preinstall_settings(){
    display_menu tengine last
    # if [ "${apache}" == "do_not_install" ]; then
    #     apache_modules_install="do_not_install"
    # else
    #     display_menu_multi apache_modules last
    # fi
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
    # local yum_list=(zlib-devel openssl-devel libxml2-devel lynx expat-devel lua-devel lua jansson-devel)

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
    # chmod 775 /alidata/server/tengine/logs
    chmod 755 /var/log/nginx/logs
    # chown -R www:www /alidata/server/tengine/logs
    chown -R www:www /var/log/nginx/logs
    # chmod -R 775 /alidata/www
    # chown -R www:www /alidata/www
    cd ..

    # cp -fR ./tengine/config-tengine/* /alidata/server/tengine/conf/
    cp -fR ./tengine/config-tengine/* ${tengine_location}/conf/  # needupdate
    sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' ${tengine_location}/conf/tengine.conf
    chmod 755 ${tengine_location}/sbin/nginx
    #/alidata/server/tengine/sbin/tengine
    # mv ${tengine_location}/sbin/tengine /etc/init.d/
    ln -s ${tengine_location}/sbin/nginx /usr/sbin/nginx
    chmod +x /usr/sbin/nginx
    nginx
# systemctl start tengine.service
# systemctl enable tengine.service

}






