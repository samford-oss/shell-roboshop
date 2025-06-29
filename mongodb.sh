#!/bin/bash

START_TIME=$(date +%s)

UserId=$(id -u)

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIRECTORY="$PWD"

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOG_FOLDER

echo "Script executing started at : $(date)"

# check the USER has ROOT Priveleges or Not
if [ $UserId -ne 0 ]; then
    echo -e "$R ERROR $N :: Please run the commands with root access" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G SUCCESS $N :: You are the root user"
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]; then
        echo -e "$2 is ... $G  SUCCESS $N" | tee -a $LOG_FILE # tee command means adding single o/p to multiple ways it add to screen and to file also
    else
        echo -e "$2 is ... $R  FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodconfig.repo
VALIDATE $? "Copying Mongo Repo config file"

dnf install mongodb-org -y &>>$LOG_FILE # redirecting to amperson log file
VALIDATE $? "Mongodb Server Installing"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongod"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE