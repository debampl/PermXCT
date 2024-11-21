######################################################
#python script for creating a combined porosityProperties file in constant folder
######################################################

import os, sys
import shutil
import time
# from timeit import default_timer as timer
# import distutils.dir_util
# from distutils.dir_util import copy_tree

path = os.getcwd()
print(path)

def main():

  start_time = time.time() 

  # KK = int(sys.argv[1])
  numSlice = int(sys.argv[1])
  numZlayers = int(sys.argv[2])

  # KK = 1
  # print(KK)

  os.chdir(path + '/combined_slice')
  path_wd = os.getcwd()
  print(path_wd)

  for KK in [1, 2, 3]:
    # open both the local porosity and permeability files 
    for nZlayers in range(numZlayers):
      if (nZlayers == 0):
        strsln = 2
      else:
        strsln = 1

      for sl in range(strsln, numSlice+1): 
        with open(path + '/SLICE_'+str(sl)+'Z'+str(nZlayers+1)+'/constant/porosityProperties_K'+str(KK),'r') as secondFile:
          with open(path_wd + '/constant/porosityProperties_K'+str(KK),'a+') as firstFile:
            i = 1
            # read content from first file 
            for line in secondFile: 
          
              if (i >= 18):
                # print(str(i), str(line))
                firstFile.write(line)
          
              i = i + 1


  # elapsedTime = (time.time() - start_time)
  # print("--- %s seconds ---" % elapsedTime)

  # Runner(args=["mpirun", "-np", str(nprocs), " porousSimpleFoam", "-parallel", ">", "foamRun.log", "&"])


if __name__ == "__main__":
   main()