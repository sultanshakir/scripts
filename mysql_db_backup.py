#!/usr/bin/env python

"""
MySQL Database Backup...
"""
import sys
import os
import subprocess
import string
import datetime

if (len(sys.argv) > 1):
  
  today = datetime.date.today()
  db_admin_usr = '' 
  db_admin_pw = ''
  db_name = sys.argv[1]
  db_backup_name = sys.argv[1] + '-' + str(today) + '.sql' 

  print 'Starting backup of db...' + sys.argv[1]
  p = subprocess.Popen('mysqldump --opt -v --user=' + db_admin_usr + ' --password=' + db_admin_pw + ' ' + db_name + ' > ' + db_backup_name, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

  for line in p.stdout.readlines():
    print line,
  
  print 'Finished backup of db...' + sys.argv[1]

else:
  print "What database should we backup?"


