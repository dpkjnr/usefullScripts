#/bin/sh
#stopping tomcat
echo "Stopping Tomcat"
CATALINA_PID=`ps -ef | grep java | grep tomcat | cut -c10-14`
kill -9  $CATALINA_PID
if test $? -eq 0 ; then
	echo "Stopped the tomcat";
else
	echo "Exiting, tomcat was NOT Stopped";
	echo $CATALINA_PID;
fi
sleep 3

echo "Doing Ant on CarDekho/Trunk"
ant > /dev/null
if test $? -eq 0 ; then
	echo "Ant successfull";
else
	echo "Exiting, ANT was NOT successfull";
	exit 1;
fi

cd ..
echo "Doing Ant ExportForMobiJar on CarDekho"
ant exportforjar > /dev/null
#ant exportforjar > /dev/null
if test $? -eq 0 ; then
	echo "Ant ExportForJar successfull";
else
	echo "Exiting, Ant ExportForJar was NOT successfull";
	exit 1;
fi

echo "backup created then car move tomcat folder and changes in some files"
NOW=$(date +"%m-%d-%Y")
echo "create backup folder name:-"$NOW
mkdir /home/mukesh/Documents/Backup_Mobile_2014/$NOW
chmod -R 777 /home/mukesh/Documents/Backup_Mobile_2014/$NOW
echo "backup car"
mv /usr/local/tomcat/webapps/car /home/mukesh/Documents/Backup_Mobile_2014/$NOW
echo "copy war file desktop "
cp -rv /media/dddfb84e-7b25-40a6-a929-671c12d71bbf/CarDekhoProject/ecarsinfo/tbsexport/car.war /home/mukesh/Desktop/
cd /home/mukesh/Desktop/
mkdir car
cd car
echo "extract tar file"
jar xf ../car.war
echo "rename file"
cd ..
mv car/ car/
echo "move war in  tomcat"
mv car/ /usr/local/tomcat/webapps/
echo "replace email properties file in tomcat"
cp -rv  /home/mukesh/Documents/Backup_Mobile_2014/$NOW/car/WEB-INF/classes/emailProperties.properties /usr/local/tomcat/webapps/car/WEB-INF/classes
if test $? -eq 0 ; then
	echo "email properties copy successfully";
else
	echo "copy in email properties";
	exit 1;
fi
echo "replace SMSMessageSendResource properties file in tomcat"
cp -rv  /home/mukesh/Documents/Backup_Mobile_2014/$NOW/car/WEB-INF/classes/SMSMessageSendResource.properties /usr/local/tomcat/webapps/car/WEB-INF/classes
echo "replace applicationContext properties file in tomcat"
cp -rv  /home/mukesh/Documents/Backup_Mobile_2014/$NOW/car/WEB-INF/classes/applicationContext.xml /usr/local/tomcat/webapps/car/WEB-INF/classes
echo "replace scriptsconfig properties file in tomcat"
cp -rv  /home/mukesh/Documents/Backup_Mobile_2014/$NOW/car/WEB-INF/classes/scriptsconfig.properties /usr/local/tomcat/webapps/car/WEB-INF/classes
echo "replace scriptsconfig properties file in tomcat"
rm -rf /usr/local/tomcat/webapps/car/WEB-INF/lib/
cp -rv  /home/mukesh/Documents/Backup_Mobile_2014/$NOW/car/WEB-INF/lib/ /usr/local/tomcat/webapps/car/WEB-INF/
if test $? -eq 0 ; then
	echo "move lib successfully";
else
	echo "error in move"
fi
rm -rf /home/mukesh/Desktop/car.war
chmod -R 777 /usr/local/tomcat/webapps/car/WEB-INF/
echo "sucessfully create war file."



#starting the tomcat
echo "starting the tomcat"
cd /usr/local/tomcat/bin/
sh catalina.sh jpda start
if test $? -eq 0 ; then
	echo "Started the tomcat";
else
	echo "Alert!! tomcat was NOT Started";
	exit 1
fi

