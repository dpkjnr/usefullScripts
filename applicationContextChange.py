#!/usr/bin/env python
import xml.etree.ElementTree as ET
import re
import sys
import os

try:
  dirPath = sys.argv[1]
except Exception, e:
  print "command line argumnets were not provided, using defaults"
  dirPath = os.path.dirname(__file__)

try:
  ip = sys.argv[2]
except Exception, e:
  print "command line argumnets were not provided, using defaults"
  ip = localhost

tree = ET.parse(dirPath+'/applicationContext.xml')
root = tree.getroot()
pattern = re.compile('(jdbc.*//)(.*)(:3306/.*)')

outputFile = open('output.xml','w')
outputFile.write('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springframework.org/dtd/spring-beans.dtd"> \n''')

for child in root:
   if child.attrib.has_key('class') and child.attrib['class'] =='org.apache.commons.dbcp.BasicDataSource':
       for ch in child:
           value=ch.attrib['value']
           name=ch.attrib['name']
           if pattern.match(value):
               o=pattern.match(value)
               groups=o.groups()
               if value.find('mariadb') != -1:
                  ch.set('value',groups[0].replace('mariadb','mysql')+ip+groups[2])
               else:
                  ch.set('value',groups[0]+ip+groups[2])
           if name=='password':
               ch.set('value','root')
           if name == 'driverClassName' and value.find('org.mariadb') != -1:
               ch.set('value',value.replace('org.mariadb','com.mysql')) 
           # if name == 'url' and value.find('mariadb') != -1:
           #     ch.set('value',value.replace('mariadb','mysql'))

tree.write(outputFile)
outputFile.close()
