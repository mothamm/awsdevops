#!/bin/bash
USER_NAME=$@
if [ -z "$USER_NAME" ]; then
    echo "Enter a Valid user name"
else
    echo "Entered user is $USER_NAME. Checkig if $USER_NAME exists..."
    USER_CHECKER=$(sudo cat /etc/passwd | cut -d ":" -f 1 | grep -w $USER_NAME)
    sleep 1
    if [ "$USER_NAME" = "$USER_CHECKER" ]; then
        echo "User $USER_NAME already exists. Please pick a separate username"
    else
        echo "Creating the user"
        PASSPEC=$(echo '!@#$%^&*()_' | fold -w1 | shuf | head -1)
        PASSWORD=$USER_NAME${RANDOM}${PASSPEC}
        sudo useradd -m $USER_NAME
        echo "$USER_NAME:$PASSWORD" | sudo chpasswd
        sudo passwd -e ${USER_NAME}
        echo "Username : $USER_NAME"
        echo "Password: $PASSWORD"
        echo "NOTE: Please change the password at your first login"
    fi
fi
