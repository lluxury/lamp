
!/bin/bash
##Enter Username and Password Details:
#userName=<UserName>
#password=<Password>
# yum install -y expect
# expect -c "
# yum install -y expect

# echo "waiting a moment"




#!/usr/bin/expect
# owner yann
# dat 04052019

# set filename [lindex $argv 0]
# set hostname [lindex $argv 1]

set filename "server"
set hostname "about0.com"

send_user "${hostname}\n"
# send_user "usage:expect filename hostname\n"



spawn openssl genrsa -des3 -out $filename.key 2048
expect "Enter pass phrase for $filename.key:"
send "1234\r"
expect "Verifying - Enter pass phrase for $filename.key:"
send "1234\r"
interact

spawn openssl rsa -in $filename.key -out $filename.key
expect "$filename.key: "
send "1234\r"
interact    # clear password

spawn openssl req -new -x509 -key $filename.key -out ca.crt -days 3650 -subj "/C=CN/ST=SH/L=SH/O=TTC/OU=it/CN=*.$hostname.com"
interact

spawn openssl req -new -key $filename.key -out $filename.csr -subj "/C=CN/ST=SH/L=SH/O=TTC/OU=it/CN=*.$hostname.com"
interact

spawn openssl x509 -req -days 3650 -in $filename.csr -CA ca.crt -CAkey $filename.key -CAcreateserial -out $filename.crt
interact







