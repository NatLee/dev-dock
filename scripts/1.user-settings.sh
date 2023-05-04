#!/bin/bash

echo "Modify user settings"

# Change root pwd
echo "root:$ROOT_PASSWORD" |chpasswd

# Check user

exists=$(grep -c "^$DEFAULT_USER:" /etc/passwd)
if [ $exists -eq 0 ]; then
    echo "Creating user $DEFAULT_USER ..."
    useradd -ms /bin/bash $DEFAULT_USER
    usermod -aG sudo $DEFAULT_USER
fi
echo "$DEFAULT_USER:$DEFAULT_USER_PASSWORD" | chpasswd