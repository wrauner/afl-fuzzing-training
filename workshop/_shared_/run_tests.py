import os
import subprocess
import sys

for subdir, dirs, files in os.walk(sys.argv[2]):
    for file in files:
        command = os.getcwd() + "/" + sys.argv[1] + " " + os.getcwd() + "/" + os.path.join(subdir, file)#
	print command
	os.system(command)


