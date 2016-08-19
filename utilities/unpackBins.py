from struct import unpack
from time import sleep

#Imports Added -BGH
import logging
import logging.config

class unpackBins(object):
        #Used to delimit header and data
        delimiter = '!@#\n'

        def __init__(self,driverName,filename):
		if driverName == 'BNO055':
			self._unpackBNO055(filename)
		elif driverName == 'MCP9808':
			self._unpackMCP9808(filename)
                elif driverName == 'ADS1015':
                        self._unpackADS1015(filename)
		elif driverName == 'MAX30100':
                        self._unpackMAX30100(filename)
                elif driverName in ['ECG2','ECG3','GSR4']:
                        self._unpackAdcIn(filename,1)
                elif driverName in ['ECG2-3']:
                        self._unpackAdcIn(filename,2)
		else:
			raise Exception
	def _getHeaderLength(self,raw):
		header = raw.split(self.delimiter)
                if len(header) == 1:
                        return 0
                else:
                        return len(header[0]) + len(self.delimiter)

	def _unpackAdcIn(self, filename, num_of_channels):
		#print('Unpacking AdcIn....')
		#Logging Event Added -BGH
		logging.info(('Unpacking AdcIn....'))

		#AdcIn data specs
		data_points = 1 + num_of_channels
		block_size = num_of_channels*2 + 1*8 #data_points * data_point_size

		#Open file and read data
		fid = open(filename,'rb+')
		raw = fid.read()		
		fid.close()

		#Get the header and remove from raw
		headerLength = self._getHeaderLength(raw)
		header = raw[0:headerLength]
		raw = raw[headerLength:]

		#extract actual numbers
		data = []
		for i in range(len(raw)/block_size):
                        unpack_format = '=' + ''.join(['H' for a in range(num_of_channels)]) + 'd'
			data.append(unpack(unpack_format,raw[i*block_size:(i+1)*block_size]))

                #New file for header
                filename_2 = filename[:-4] + '_meta.txt'
		fid = open(filename_2,'w')
                fid.write('Original Header:\n\n' + header)
                newHeader =  '\nCSV Header:\n\n'
                newHeader += 'The voltages are now in volts.\n'
                newHeader += 'The time is in seconds, subtracting off the startTime.\n'
                newHeader += self.delimiter 
                fid.write(newHeader)
		fid.close()

		#Iterate through each line, then each data point
		filename_3 = filename[:-4] + '.csv'
		fid = open(filename_3,'w')
		fid.write('volt, time\n')
                f = "{:.3f}"
                #startTime = data[0][1]
		for i in range(len(data)):
                        #Voltage
                        
                        voltage = []
                        for c in range(num_of_channels):
                            voltage.append(float(data[i][c])/1000.0)
			    fid.write(f.format(voltage[-1]) + ', ')

                        #Time
                        fid.write("{:.6f}".format(data[i][-1]) + '\n')

		#Close file
		fid.close()
		#print('Done!')
		#Logging Event Added -BGH
		logging.info('Done Unpacking ADCIn')




	def _unpackBNO055(self, filename):
		#print('Unpacking BNO055....')
		#Logging Event Added -BGH
		logging.info('Unpacking BNO055....')

		#BNO055 data specs
		data_points = 10
		data_point_size = 4 #Bytes
		block_size = 9*2 + 1*8 #data_points * data_point_size
		offset = pow(2,15) #This error is caused at times due to slow switching times (it seems)

		#Open file and read data
		fid = open(filename,'rb+')
		raw = fid.read()		
		fid.close()

		#Get the header and remove from raw
		headerLength = self._getHeaderLength(raw)
		header = raw[0:headerLength]
		raw = raw[headerLength:]

		#extract actual numbers
		data = []
		for i in range(len(raw)/block_size):
			data.append(unpack('=9hd',raw[i*block_size:(i+1)*block_size]))
	
		#Correct errors
		detection = pow(2,14)
		for i in range(len(data)):
			for ii in range(data_points-1):
				temp_data_point = data[i][ii]
				if temp_data_point > detection:
					temp_data = list(data[i])
					temp_data[ii] = temp_data[ii] - offset
					data[i] = tuple(temp_data)
				elif temp_data_point < (-1)*(detection):
					temp_data = list(data[i])
					temp_data[ii] = temp_data[ii] + offset
					data[i] = tuple(temp_data)

		#New file
		filename_2 = filename[:-4] + '_meta.txt'
		fid = open(filename_2,'w')
                fid.write('Original Header:\n\n' + header + '\nCSV Header:\n\n')
                newHeader  = 'All the accelerometer values are in m/s^2.\n'
                newHeader += 'All magnetometer values are in microteslas.\n'
                newHeader += 'All gyroscope values are in degrees per second.\n'
                newHeader += 'The time is in seconds, subtracting off the startTime.\n'
                newHeader += 'The data is organized in this format:\n'
                newHeader += 'accelx,accely,accelz,accelMagnitude,'
                newHeader += 'magnetx,magnety,magnetz,magnetMagnitude,'
                newHeader += 'gyrox,gyroy,gyroz,gyroMagnitude,time\n'
                newHeader += self.delimiter
                fid.write(newHeader)
		fid.close()

		#Iterate through each line
                filename_3 = filename[:-4] + '.csv'
		fid = open(filename_3,'w')
		fid.write('accel_x, accel_y, accel_z, accel_magnitude, magnet_x, magnet_y, ')
		fid.write('magnet_z, magnet_magnitude, gyro_x, gyro_y, gyro_z, gyro_magnitude, time\n')
		#startTime = data[0][9]
		for i in range(len(data)):
                        #Format
                        f = "{:.3f}"
                        #accelerometer
                        accelx = float(data[i][0])/100.0
                        accely = float(data[i][1])/100.0
                        accelz = float(data[i][2])/100.0
                        accelMag = pow(accelx*accelx+accely*accely+accelz*accelz,.5)
                        fid.write(f.format(accelx)   + ', ')
                        fid.write(f.format(accely)   + ', ')
                        fid.write(f.format(accelz)   + ', ')
                        fid.write(f.format(accelMag) + ', ') #Magnitude
                        
                        #Magnetometer
                        magnetx = float(data[i][3])/16.0
                        magnety = float(data[i][4])/16.0
                        magnetz = float(data[i][5])/16.0
                        magnetMag = pow(magnetx*magnetx+magnety*magnety+magnetz*magnetz,.5)
                        fid.write(f.format(magnetx)   + ', ')
                        fid.write(f.format(magnety)   + ', ')
                        fid.write(f.format(magnetz)   + ', ')
                        fid.write(f.format(magnetMag) + ', ')
                        
                        #Gyroscope
                        gyrox = float(data[i][6])/16.0
                        gyroy = float(data[i][7])/16.0
                        gyroz = float(data[i][8])/16.0
                        gyroMag = pow(gyrox*gyrox+gyroy*gyroy+gyroz*gyroz,.5)
                        fid.write(f.format(gyrox)   + ', ')
                        fid.write(f.format(gyroy)   + ', ')
                        fid.write(f.format(gyroz)   + ', ')
                        fid.write(f.format(gyroMag) + ', ')

                        #Time
                        fid.write("{:.6f}".format(data[i][9]) + '\n')

		#Close file
		fid.close()
		#print('Done!')
		#Logging Event Added -BGH
		logging.info('Done Unpacking BNO055')

	def _unpackMCP9808(self, filename):
		#print('Unpacking MCP9808....')
		#Logging Event Added -BGH
		logging.info('Unpacking MCP9808....')
		#MCP9808 data specs
		data_points = 2
		data_point_size = 4 #Bytes
		block_size = 4 + 8#data_points * data_point_size

		#Open file and read data
		fid = open(filename,'rb+')
		raw = fid.read()		
		fid.close()

		#Get the header and remove from raw
		headerLength = self._getHeaderLength(raw)
		header = raw[0:headerLength]
		raw = raw[headerLength:]

		#extract actual numbers
		data = []
		for i in range(len(raw)/block_size):
			data.append(unpack('=fd',raw[i*block_size:(i+1)*block_size]))
	
		#New file
		filename_2 = filename[:-4] + '_meta.txt'
		fid = open(filename_2,'w')
                fid.write('Original Header:\n\n' + header)
                newHeader =  '\nCSV Header:\n\n'
                newHeader += 'The time is in seconds, subtracting off the startTime.\n'
                newHeader += self.delimiter
                fid.write(newHeader)
		fid.close()

		#Iterate through each line, then each data point
                filename_3 = filename[:-4] + '.csv'
		fid = open(filename_3,'w')
		fid.write('temperature, time\n')
		#startTime = data[0][1]
                f = "{:.3f}"
		for i in range(len(data)):
			fid.write(f.format(data[i][0]) + ', ')
                        fid.write("{:.6f}".format(data[i][1]))
			fid.write('\n')

		#Close file
		fid.close()
		#print('Done!')
		#Logging Event Added -BGH
		logging.info('Done Unpacking MCP9808!')

	def _unpackADS1015(self, filename):
		#print('Unpacking ADS1015....')
		#Logging Event Added -BGH
		logging.info('Unpacking ADS1015....')
		#MCP9808 data specs
		data_points = 4
		data_point_size = 4 #Bytes
		block_size = 2*3 + 8#data_points * data_point_size

		#Open file and read data
		fid = open(filename,'rb+')
		raw = fid.read()		
		fid.close()
	
		#Get the header and remove from raw
		headerLength = self._getHeaderLength(raw)
		header = raw[0:headerLength]
		raw = raw[headerLength:]

		#extract actual numbers
		data = []
		for i in range(len(raw)/block_size):
			data.append(unpack('=HHHd',raw[i*block_size:(i+1)*block_size]))
                        #print unpack('=HHHd',raw[i*block_size:(i+1)*block_size])
	
		#New file
		filename_2 = filename[:-4] + '_meta.txt'
		fid = open(filename_2,'w')
                fid.write('Original Header:\n\n' + header + '\nCSV Header:\n')
                newHeader = 'All the values are now in Volt units.\n'
                newHeader += 'The time is in seconds, subtracting off the startTime.\n'
                newHeader += self.delimiter 
                fid.write(newHeader)
            	fid.close()

		#Iterate through each line, then each data point
                filename_3 = filename[:-4] + '.csv'
		fid = open(filename_3,'w')
		fid.write('voltage_1, voltage_2, voltage_3, time\n')
		#startTime = data[0][3]
                f = "{:.3f}"
		for i in range(len(data)):
			#Channel 3
                        voltage3 = float(data[i][0])/1000.0
                        fid.write(f.format(voltage3) + ', ')

                        #Channel 2
                        voltage2 = float(data[i][1])/1000.0
                        fid.write(f.format(voltage2) + ', ')

                        #Channel 1
                        voltage1 = float(data[i][2])/1000.0
                        fid.write(f.format(voltage1) + ', ')

                        #Time
                        fid.write("{:.6f}".format(data[i][data_points-1]))
			fid.write('\n')

		#Close file
		fid.close()
		#print('Done!')
		#Logging Event Added -BGH
		logging.info('Done Unpacking ADS1015!')

	def _unpackMAX30100(self, filename):
		#print('Unpacking MAX30100....')
		#Logging Event Added -BGH
		logging.info('Unpacking MAX30100...')

		#BNO055 data specs
		data_points = 4
		#data_point_size = 4 #Bytes
		block_size = 2*2 + 1*4 + 1*8 #data_points * data_point_size
		
		#Open file and read data
		fid = open(filename,'rb+')
		raw = fid.read()		
		fid.close()

		#Get the header and remove from raw
		headerLength = self._getHeaderLength(raw)
		header = raw[0:headerLength]
		raw = raw[headerLength:]

		#extract actual numbers
		data = []
		for i in range(len(raw)/block_size):
			data.append(unpack('=HHfd',raw[i*block_size:(i+1)*block_size]))
	
		#New file
		filename_2 = filename[:-4] + '_meta.txt'
		fid = open(filename_2,'w')
                fid.write('Original Header:\n' +header + '\nCSV Header:\n')
                newHeader = 'The time is in seconds, subtracting off the startTime.\n'
                newHeader += self.delimiter 
                fid.write(newHeader)
		fid.close()

		#Iterate through each line, then each data point
		filename_3 = filename[:-4] + '.csv'
		fid = open(filename_3,'w')
		fid.write('ir, red, temperature, time\n')
                #startTime = data[0][3]
                f = "{:.3}"
		for i in range(len(data)):
		        #IR
                        fid.write(str(data[i][0]) + ', ')

                        #Red
                        fid.write(str(data[i][1]) + ', ')

                        #Temp
                        fid.write(f.format(data[i][2]) + ', ')

                        #Time
                        fid.write("{:.6f}".format(data[i][3]))
			fid.write('\n')

		#Close file
		fid.close()
		#print('Done!')
		#Logging Event Added -BGH
		logging.info('Done Unpacking MAX30100!')


