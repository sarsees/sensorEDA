from unpackBins import unpackBins
from glob import glob
from os import getcwd as pwd
import os
import subprocess
import sys

def process(path, ext):
	#Look in the current path
	cwd = glob(path + '/*')

	#Iterate through all the elements in the path
	for i in cwd:
		#If an element has the same extention as desired, execute code
		if i[-(len(ext)):] == ext:
			#Run code on element
			sensor_type = getSensorType(i)
			temp = unpackBins(sensor_type,i)

		#Recursively continue
		process(i,ext)

def getSensorType(path):
	#Split by slashes
	directories = path.split('/')
	filename = directories[-1]
	file_breakdown = filename.split('_')
	print(file_breakdown[6])
	return file_breakdown[6]


#Save the old directory and change directories
pwd = subprocess.check_output('pwd')[0:-1]
cwd =  os.path.dirname(os.path.realpath(__file__))
os.chdir(cwd)
    
#Get the file directory
try:
	path = sys.argv[1]
except:
	print('ERROR: No path specified')

#Process the files in that directory
process(path,'.bin')

#Change back to previous directory
os.chdir(pwd)
