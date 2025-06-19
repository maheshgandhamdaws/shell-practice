#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[35m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo 14-logs.sh | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" &>>$LOG_FILE

if [ $USERID -ne 0]
then
    echo -e "$R ERROR:: Please run this script with root access $N" &>>$LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo -e "$B You are running with root access $N" &>>$LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "Installing $2 is ...$G SUCCESS $N" &>>$LOG_FILE
    else
        echo -e "Installing $2 is ...$R FAILURE $N" &>>$LOG_FILE
        exit 1
    fi
   
}

apt list installed mysql
if [ $? -ne 0 ]
then
    echo "MYSQL is not installed... going to install it" &>>$LOG_FILE
    apt install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "MYSQL"
else
    echo -e "Nothing to do MYSQL... $Y already installed $N" &>>$LOG_FILE
fi

apt list installed python3 &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "python3 is not installed... going to install it" &>>$LOG_FILE
    apt install python3 -y &>>$LOG_FILE
    VALIDATE $? "python3"
else
    echo -e "Nothing to do python3... $Y already installed $N" &>>$LOG_FILE
fi

apt list installed nginx &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "nginx is not installed... going to install it" &>>$LOG_FILE
    apt install nginx -y &>>$LOG_FILE
    VALIDATE $? "nginx"
else
    echo -e "Nothing to do nginx... $Y already installed $N" &>>$LOG_FILE
fi  