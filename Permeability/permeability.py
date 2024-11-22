# Calculate the permeability for each generation
# Read flow rate form the post-processing directory
# in OpenFoam Linux

import os
import numpy as np
import sys

path = os.getcwd()
print(path)

def main():

	KK = int(sys.argv[1])
	Q_surf = str(sys.argv[2])
	endStep = 200 # nt(sys.argv[3])
	# threshold = str(sys.argv[3])
	Vf = float(sys.argv[3])
	NX = str(sys.argv[4])
	NY = str(sys.argv[5])
	NZ = str(sys.argv[6])
	SKIP = str(sys.argv[7])
	
	flowRatePath = path + "/postProcessing/flowRatePatch(name="+str(Q_surf)+")/"+str(endStep)+"/"
	# print(path)
	# flowRatePath = path + "/postProcessing/flowRatePatch(name=sidesX2)/200/"

	print(flowRatePath)

	flowRateFile = open(flowRatePath + "surfaceFieldValue.dat","r+")
	flowRateFile.seek(0) 
	flowRate = np.loadtxt(flowRateFile, skiprows=5, usecols=[0,1])

	print(flowRate.shape)
	
	# n = len(flowRate)
	# fRate = flowRate[n-1][1]
	# print(n)
	print('Flow rate : %g' % float(flowRate[1]))


	# Update Lx, Ly, Lz, and  pixel dimension here check with the gemetric representation in paraview 
	# It is a rotated XZ co-ordinated in the present scan.
	Lx = NZ*SKIP*13.96607*1e-6	# [m2]
	Ly = NY*SKIP*13.96607*1e-6	# [m2]
	Lz = NX*SKIP*13.96607*1e-6	# [m2]

	# Update Flow properties
	rho = 1.185 # density
	mu	= 1.831e-5	# viscosity
	P1 = 0.1 # inlet pressure
	P2 = 0.001 # outlet pressure

	###########################################################################
	######## This directional change has been incroporated to match with fiber orientation and the predicted permeability direction
	if KK == 1:
		permeabilityK = (1-Vf)*flowRate[1]*(Lx*mu)/((Ly*Lz)*(P1-P2))
		print('permeability K3: %g'% float(permeabilityK))
		domainD = open(path + f"/Permeability_K33_XCT.txt", "w+")
		domainD.write('Domain dimensions\n')
		domainD.write('Lx(mm) Ly(mm) Lz(mm)\n')
		domainD.write(str(Lz*1e3) + ' ' + str(Ly*1e3) + ' ' + str(Lx*1e3) +'\n')
		str1 = "Current Global VF\n"
		str2 = str(Vf)+"\n"
		domainD.write(str1)
		domainD.write(str2)
		domainD.write('permeability K3    '+ str(permeabilityK))
		domainD.close()

	if KK == 2:
		permeabilityK = (1-Vf)*flowRate[1]*(Ly*mu)/((Lx*Lz)*(P1-P2))
		print('permeability K2: %g'% float(permeabilityK))
		domainD = open(path + f"/Permeability_K22_XCT.txt", "w+")
		domainD.write('Domain dimensions\n')
		domainD.write('Lx(mm) Ly(mm) Lz(mm)\n')
		domainD.write(str(Lz*1e3) + ' ' + str(Ly*1e3) + ' ' + str(Lx*1e3) +'\n')
		str1 = "Current Global VF\n"
		str2 = str(Vf)+"\n"
		domainD.write(str1)
		domainD.write(str2)
		domainD.write('permeability K2    '+ str(permeabilityK))
		domainD.close()

	if KK == 3:
		permeabilityK = (1-Vf)*flowRate[1]*(Lz*mu)/((Lx*Ly)*(P1-P2))
		print('permeability K1: %g'% float(permeabilityK))
		domainD = open(path + f"/Permeability_K11_XCT.txt", "w+")
		domainD.write('Domain dimensions\n')
		domainD.write('Lx(mm) Ly(mm) Lz(mm)\n')
		domainD.write(str(Lz*1e3) + ' ' + str(Ly*1e3) + ' ' + str(Lx*1e3) +'\n')
		str1 = "Current Global VF\n"
		str2 = str(Vf)+"\n"
		domainD.write(str1)
		domainD.write(str2)
		domainD.write('permeability K1    ' + str(permeabilityK))
		domainD.close()


if __name__ == "__main__":
   main()

