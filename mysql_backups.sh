#!/bin/bash
############################################################################
# Name    : mysql_backups.sh
# Explain : This is a backup the mysql database scripts .
# Author  : Chen Hao
# Email   : 935048000@qq.com
#
# Backups Path    : from all database  to /backups/mysql/
# Backups date    : Every day 1:00 start
# Backups crontab : 
# 0 1 * * * /bin/bash /shell_script/mysql_backups.sh backup > /dev/null 2>&1 &
############################################################################

#env parameter
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
Date=$(date +"%Y-%m-%d")
DATE=$(date +"%Y-%m-%d-%H:%M")
SHELL_NAME="mysql_backups.sh"
FILE_NAME=mysql-$Date
FILE_SIZE=$(du -sh /mysql/ | cut -f1)
LOG_FILE=/backups/log/backups.log
BACKUP_S=/mysql/data/*
BACKUP_D=/backups/mysql/
PORT=`netstat -nlt|grep 3306|wc -l`




#Log function
shell_log(){
	LOG_INFO=$1
    echo "$DATE : ${SHELL_NAME} : ${LOG_INFO} : file size= ${FILE_SIZE} "  >> ${LOG_FILE}
}


#The backup data
backup(){
	innobackupex --host=127.0.0.1 --user=sync --password=sync_xueshengchu --defaults-flie=/etc/my.cnf $BACKUP_D$FILE_NAME
	if [[ $? -eq 0 ]];then
		shell_log " [SUCCESS] MySQL Data Backups "

	else
		shell_log " [ERROR]   MySQL Data Backups "
	fi
	#sleep 60
}

#look mysql status
recover(){
	mv $BACKUP_S /tmp/
	echo -n "请输入需要恢复的数据的绝对路径(在$BACKUP_D下选择其一) ："
	read value1
	innobackupex --defaults-flie=/etc/my.cnf --apply-log $value
	sleep 3
	innobackupex --defaults-flie=/etc/my.cnf --copy-back $value
	chown -R mysql:mysql /mysql
	service mysqld start
}

#mysql start
mysql_start(){
	echo -n "输入y则自动启动数据库，输入n则退出脚本:"
	read value2
	case $value2 in
        y)
        	service mysqld start
        	if [[ $? -eq 0 ]];then
				echo "数据库启动成功。"
			else
				echo "[ERROR]:数据库启动失败,请在mysql日志中查看报错信息。"
				exit 2
			fi
            ;;
        n)
			echo "成功退出！"
            exit 0
            ;;
        *)
            echo "[ERROR]:输入错误！";
            exit 4
    esac
}

#data recover
mysql_look(){
	if [ $PORT -eq 1 ];then
		service mysqld stop
		if [[ $? -eq 0 ]];then
			recover
		else
			echo  "数据库关闭失败，数据库不能关闭或者没有启动。"
			mysql_start
		fi
	else
		recover
	fi
}



#Delete expired backup data
delete(){
	find $BACKUP_D -name "mysql-*" -mtime +7 -exec rm -rf {} \;
	if [[ $? -eq 0 ]];then
		shell_log " [SUCCESS] MySQL Delete "
	else
		shell_log " [ERROR]   MySQL Delete "
	break
	fi
}


# Main Function
main(){
	case $1 in
        backup)
			delete
            backup
            ;;
        recover)
            mysql_look
            ;;
        *)
			echo "参数错误"
        	exit 5
    esac
}

main $1
