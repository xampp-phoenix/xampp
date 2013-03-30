'''
Created on 30.06.2012

@author: Kay Vogelgesang 
@version: mailtodisk 1.0 
@copyright: Kay Vogelgesang, XAMPP - apachefriends.org  
@license: Apache License Version 2.0
@note: Win32 executable was built with PyInstaller 1.5 

'''

import os
import sys
from time import gmtime,strftime
from datetime import datetime
import win32com.client as com


class MailToDisk():
    
    maildirectory = os.path.join(os.getcwd(), 'mailoutput')
    dt = datetime.now()
    filename = "mail-%s-%s.txt" % (strftime("%Y%m%d-%H%M", gmtime()),dt.microsecond) # filename with date + time + milliseconds
    filename = "%s\%s" % (maildirectory,filename)
    
    # Security restriction: mailoutput folder may not have more then 300 MB overall size for write in 
    if os.path.exists(maildirectory):
        filesize = com.Dispatch("Scripting.FileSystemObject")
        folder = filesize.GetFolder(maildirectory)
        if folder.Size > 314572800: # 300 MB 
            warnfile =  "%s\%s" % (maildirectory,"MAILTODISK_WRITE_RESTRICTION_FOLDER_MORE_THEN_300_MB.txt")
            f = open(warnfile, 'w')
            f.write("MailtoDisk will NOT write in folder with a overall size of 300 MB (security limit). Please clean up this folder.")
            f.close()
            sys.exit(1)
       
    def readstin(self):
        line = ""
        # read stdin line by line
        while 1:
            next = sys.stdin.readline()         
            line = "%s%s" % (line,next)
            if not next:                        # break if empty string at EOF
                break
        return line
            
    def writemail(self):          
        if not os.path.exists(self.maildirectory):
                os.makedirs(self.maildirectory)
        line = self.readstin()
        # write mail in a separate file
        f = open(self.filename, 'w')
        f.write(line)
        f.close()
 

if __name__ == '__main__':
    writetodisk = MailToDisk()
    writetodisk.writemail()
    sys.exit()