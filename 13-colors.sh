#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[35m"
N="\e[0m"

if [ $USERID -ne 0]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access"
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is ...$G SUCCESS $N"
    else
        echo -e "Installing $2 is ...$R FAILURE $N"
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
    echo -e "Nothing to do MYSQL... $Y already installed $N"
fi

apt list installed python3
if [ $? -ne 0 ]
then
    echo "python3 is not installed... going to install it"
    apt install python3 -y
    VALIDATE $? "python3"
else
    echo -e "Nothing to do python3... $Y already installed $N"
fi

apt list installed nginx
if [ $? -ne 0 ]
then
    echo "nginx is not installed... going to install it"
    apt install nginx -y
    VALIDATE $? "nginx"
else
    echo -e "Nothing to do nginx... $Y already installed $N"
fi