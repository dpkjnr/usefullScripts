#/bin/sh
#stopping tomcat
TOMCAT_DIRECTORY_PATH=/usr/local/tomcat  #need to be changed
CARDEKHO_PROJECT_DIRECTORY_PATH=/media/disk1/CarDekho/ecarsinfo/trunk  #need to be changed
BACKUP_DIRECTORY_PATH=/media/disk1/car_backups #need to be changed

cd $CARDEKHO_PROJECT_DIRECTORY_PATH
echo "getting update from svn head"
RESULT=`svn up` | grep applicationContext.xml
if [ -z "$RESULT" ]; then
	echo "file applicationContext.xml is unchanged .."
	FLAG=FALSE
else
	echo "file applicationContext.xml is changed(updated) .."
	FLAG=TRUE
fi

echo "Stopping Tomcat"
PID=`ps aux | grep tomcat | awk '{print $2}'`
L=`echo $PID | awk '{print NF}'`
if test $L -gt 1 ; then
	`echo $PID | awk '{for(i=1; i<NF; i++) print $i}' | xargs kill -9`;
fi

if test $? -eq 0 ; then
	echo "Stopped the tomcat";
else
	echo "Exiting, tomcat was NOT Stopped";
fi
sleep 3

echo "runnig command Ant in directory $pwd"
`sudo ant` > /dev/null
if test $? -eq 0 ; then
	echo "Ant successfull";
else
	echo "Exiting, ANT was NOT successfull";
	exit 1;
fi

cd ..
echo "running command Ant ExportForJar on CarDekho"
`ant exportforjar` > /dev/null
#ant exportforjar > /dev/null
if test $? -eq 0 ; then
	echo "Ant ExportForJar successfull";
else
	echo "Exiting, Ant ExportForJar was NOT successfull";
	exit 1;
fi

echo "backup created then car move tomcat folder and changes in some files"
NOW=$(date +"%m-%d-%Y:%I%p")
echo "create backup folder name:-"$NOW
mkdir $BACKUP_DIRECTORY_PATH/$NOW
chmod -R 777 $BACKUP_DIRECTORY_PATH/$NOW
echo "backup car"
mv $TOMCAT_DIRECTORY_PATH/webapps/car $BACKUP_DIRECTORY_PATH/$NOW
echo "copy war file desktop "
`cp $CARDEKHO_PROJECT_DIRECTORY_PATH/../tbsexport/car.war /home/$USER/Desktop/`
cd /home/$USER/Desktop/
mkdir car
cd car
echo "extract tar file"
jar xf ../car.war
echo "rename file"
cd ..
mv car/ car/
echo "move war in  tomcat"
mv car/ $TOMCAT_DIRECTORY_PATH/webapps/
echo "replace email properties file in tomcat"
cp  $BACKUP_DIRECTORY_PATH/$NOW/car/WEB-INF/classes/emailProperties.properties $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes
if test $? -eq 0 ; then
	echo "email properties copy successfully";
else
	echo "copy in email properties";
	exit 1;
fi
echo "replace SMSMessageSendResource properties file in tomcat"
cp -rv  $BACKUP_DIRECTORY_PATH/$NOW/car/WEB-INF/classes/SMSMessageSendResource.properties $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes

if test $FLAG -eq FALSE ; then
	echo "replace applicationContext properties file in tomcat"
	cp -rv  $BACKUP_DIRECTORY_PATH/$NOW/car/WEB-INF/classes/applicationContext.xml $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes
else
	sudo python applicationContextChange.py $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes #provide custom ip
	sudo mv output.xml $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes/applicationContext.xml

echo "replace scriptsconfig properties file in tomcat"
cp -rv  $BACKUP_DIRECTORY_PATH/$NOW/car/WEB-INF/classes/scriptsconfig.properties $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/classes
echo "replace lib in tomcat"
sudo rm -rf $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/lib/
cp -rv  $BACKUP_DIRECTORY_PATH/$NOW/car/WEB-INF/lib/ $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/
if test $? -eq 0 ; then
	echo "move lib successfully";
else
	echo "error in move"
fi
rm -rf /home/$USER/Desktop/car.war
chmod -R 777 $TOMCAT_DIRECTORY_PATH/webapps/car/WEB-INF/
echo "sucessfully create war file."



#starting the tomcat
echo "starting the tomcat"
cd $TOMCAT_DIRECTORY_PATH/bin/
sh catalina.sh jpda start
if test $? -eq 0 ; then
	echo "Started the tomcat";
else
	echo "Alert!! tomcat was NOT Started";
	exit 1
fi

