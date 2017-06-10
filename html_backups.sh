#!/bin/bash
############################################################################
# Name    : html_backups.sh
# Explain : This is a backup site script code .
# Author  : Chen Hao
# Email   : 935048000@qq.com
#
# Backups Path    : from /www/html/  to /backups/web/
# Backups date    : Every Sunday 2:00 start
# Backups crontab : 
# 0 2 * * 7 /bin/bash /shell_script/html_backups.sh > /dev/null 2>&1 &
############################################################################

#env parameter
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
Date=$(date +"%Y-%m-%d")
DATE=$(date +"%Y-%m-%d-%H:%M")
SHELL_NAME="html_backups.sh"
FILE_NAME=html-$Date
FILE_SIZE=$(du -sh /www/html | cut -f1)
LOG_FILE=/backups/log/backups.log
BACKUP_S=/www/html/
BACKUP_D=/backups/web/

#Log function
shell_log(){
	LOG_INFO=$1
    echo "$DATE : ${SHELL_NAME} : ${LOG_INFO} : file size= ${FILE_SIZE} "  >> ${LOG_FILE}
}


#The backup data
backup(){
	tar -cPzf $BACKUP_D$FILE_NAME.tar.gz $BACKUP_S
	if [[ $? -eq 0 ]];then
		shell_log " [SUCCESS] HTML Code Backups "

	else
		shell_log " [ERROR]   HTML Code Backups "
	break
	fi
	#sleep 60
}


#Delete expired backup data
delete(){
	find $BACKUP_D -name "html-*.tar.gz" -mtime +14 -exec rm -rf {} \;
	if [[ $? -eq 0 ]];then
		shell_log " [SUCCESS] HTML Delete "
	else
		shell_log " [ERROR]   HTML Delete "
	break
	fi
}


# Main Function
main(){
	delete
	backup
}

main
