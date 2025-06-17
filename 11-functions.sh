#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0]
then
    echo "ERROR:: Please run this script with root access"
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access"
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo "Installing $2 is ... SUCCESS"
    else
        echo "Installing $2 is ... FAILURE"
        exit 1
    fi
   
}

apt list installed mysql
if [ $? -ne 0 ]
then
    echo "MYSQL is not installed... going to install it"
    apt install mysql-server -y
    VALIDATE $? "MYSQL"
else
    echo "MYSQL is already installed...Nothing to do"
fi

apt list installed python3
if [ $? -ne 0 ]
then
    echo "python3 is not installed... going to install it"
    apt install python3 -y
    VALIDATE $? "python3"
else
    echo "python3 is already installed...Nothing to do"
fi

apt list installed nginx
if [ $? -ne 0 ]
then
    echo "nginx is not installed... going to install it"
    apt install nginx -y
    VALIDATE $? "nginx"
else
    echo "nginx is already installed...Nothing to do"
fi