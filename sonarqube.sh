#!/bin/bash

# ------------------------ Color Codes ------------------------
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[35m"
N="\e[0m"

# ------------------------ Variables --------------------------
USERID=$(id -u)
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

SONAR_VERSION="10.5.1.90531"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"
INSTALL_DIR="/opt/sonarqube"
SONAR_USER="sonarqube"

# ------------------------ Prerequisites -----------------------
mkdir -p "$LOGS_FOLDER"
echo "Script started at: $(date)" | tee -a "$LOG_FILE"

if [ "$USERID" -ne 0 ]; then
    echo -e "$R ERROR: Please run this script as root. $N" | tee -a "$LOG_FILE"
    exit 1
else
    echo -e "$B Running with root access. $N" | tee -a "$LOG_FILE"
fi

# ------------------------ Function --------------------------
VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOG_FILE"
    else
        echo -e "$2 ... $R FAILURE $N" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# ------------------------ Install Java ----------------------
echo -e "$Y Installing OpenJDK 17 $N" | tee -a "$LOG_FILE"
apt update -y &>>"$LOG_FILE"
apt install openjdk-17-jdk unzip wget -y &>>"$LOG_FILE"
VALIDATE $? "Installing Java, unzip, wget"

# ------------------------ Create User -----------------------
id $SONAR_USER &>/dev/null
if [ $? -ne 0 ]; then
    useradd -r -s /bin/false $SONAR_USER
    VALIDATE $? "Creating SonarQube user"
fi

# ------------------------ Download SonarQube ----------------
echo -e "$Y Downloading SonarQube $N" | tee -a "$LOG_FILE"
wget $SONARQUBE_URL -O /tmp/sonarqube.zip &>>"$LOG_FILE"
VALIDATE $? "Downloading SonarQube"

unzip -o /tmp/sonarqube.zip -d /opt/ &>>"$LOG_FILE"
mv /opt/sonarqube-${SONAR_VERSION} $INSTALL_DIR &>>"$LOG_FILE"
chown -R $SONAR_USER:$SONAR_USER $INSTALL_DIR

# ------------------------ Create SystemD Service ------------
echo -e "$Y Creating systemd service for SonarQube $N" | tee -a "$LOG_FILE"
cat <<EOF >/etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=$INSTALL_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$INSTALL_DIR/bin/linux-x86-64/sonar.sh stop
User=$SONAR_USER
Group=$SONAR_USER
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

VALIDATE $? "Creating SonarQube systemd service"

# ------------------------ Start SonarQube -------------------
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sonarqube &>>"$LOG_FILE"
systemctl start sonarqube &>>"$LOG_FILE"
systemctl status sonarqube | tee -a "$LOG_FILE"

# ------------------------ Completion ------------------------
echo -e "$G SonarQube installed successfully! Access it at http://<your-ip>:9000 $N" | tee -a "$LOG_FILE"
