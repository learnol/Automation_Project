apt update-y
dpkg -s apache2 &> /dev/null
if [ $? -ne 0 ]
then
	echo "Apache server not installed"
        sudo apt install apache2
else
	echo "Apache server already installed"
fi

if [ $(pgrep apache2 | wc -l) -eq 0 ]
then
	echo "Apache service is down"
	sudo service apache2 start
else
	echo "Apache service is UP and Running"
fi
#if [ $(systemctl is-enabled apache2 | grep -v enables) eq enabled ]
#then
#	echo "on bootup apache is running"
#else
#	echo " Starting service on ec2 bootup"
#	service apache2 restart
#fi


if [ $(/etc/init.d/apache2 status | grep -v grep | grep 'Apache2 is running' | wc -l) > 0 ]
then 
	echo "apache service running"
else
	echo "Apache service not running"
	service apache2 restart
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
myname=priyanka
s3_bucket=upgrad-priyanka
tar -cvf  /tmp/${myname}-httpd-logs-${timestamp}.tar  /var/log/apache2/access.log /var/log/apache2/error.log
sudo apt update
apt install awscli -y
aws s3 \
	cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
	s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

IFS='
'
execute=`find /tmp -mmin -1 -type f -exec ls -lh {} +`
cat /var/www/html/inventory.html
if [ $? != 0 ]
then
        echo -e "Log Type  \tDate Created  \t Type \t Size" >>  /var/www/html/inventory.html
    execute=`ls -lh /tmp/*-httpd-logs*.tar`
fi

trs=""
for line in $execute;
do
    Size=`echo $line| awk '{print $5}'`
    file=`echo $line| awk -F/ '{ print $3}'`
    LogType=`echo  $file | awk -F- '{ print $2"-"$3}'`
    time=`echo $file | awk -F- '{print $NF}'|awk -F. '{print $1}'`
    date=`echo  $file | awk -F- '{ print $4}'`
    DateCreated=`echo $date"-"$time`
    Type=`echo  $file | awk -F. '{print $2}'`

    echo -e "$LogType  \t$DateCreated  \t$Type \t$Size" >>  /var/www/html/inventory.html
done
cat /etc/cron.d/automation  > /dev/null 2>&1
if [ $? != 0 ]
then
        echo "0 0 * * *  root /root/Automation_Project/automation.sh" >>  /etc/cron.d/automation
fi

