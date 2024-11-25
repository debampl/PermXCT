#!/bin/bash
source ~/.bashrc
shopt -s expand_aliases

start=$(date +%s)

set -e # makes the script quite if any command gives a non-zero exit code

nprocs=16	######### Number of processor for parallel simulation
numSlice=16 ########## number of slices in XY plane
numZlayers=4 ########## number of Z layes this the division from 4x4x4 unit cell

# KK=1 	############## Permeability direction

dir=/mnt/c/Users/debaa/Desktop/SoftwareXPaperGitHub/Permeability

parentdir=$(builtin cd $dir; pwd)
echo $parentdir

thresholdWD=/Dom148x228x36/Thresold36784skippVox4

####### Calculate the global fiber Vf from the XCT analysis and update it here.
Vf=0.54242
NX=148
NY=228
NZ=36
SKIP=4

# #################### Install DREAM3D and call the PipelinerRunner
# #### This block of code will create the FE mesh based on the perdefined class file from the JSON file of each slices
# for((k=1; k<=$numZlayers; k++));	do
# 	for((i=1; i<=$numSlice; i++));	do

# 		/home/aerodeb/DREAM3D/bin/PipelineRunner -p $parentdir/$thresholdWD/SLICE_$i\Z$k/*.json

# 	done
# done
# end=$(date +%s)
# echo "Elapsed Time: $(($end-$start)) seconds"

# ### After creation of individaul blocks, you can visualize the block in paraview by opening the slice_*.xdmf file.

# echo $parentdir

# #################### Copy the pre-requisite openfoam file of 0.setup, constant.setup, system.setup and combiLocalPorosityProp.py to the $thresholdWD file
# #################### Because the rest of the permeability simulation will run from the $thresholdWD
# cp -r $parentdir/0.setup $parentdir/$thresholdWD/0.setup
# cp -r $parentdir/constant.setup $parentdir/$thresholdWD/constant.setup
# cp -r $parentdir/system.setup $parentdir/$thresholdWD/system.setup
# cp -r $parentdir/combiLocalPorosityProp.py $parentdir/$thresholdWD/combiLocalPorosityProp.py

cd $parentdir

####################################################################################################################################
#################### MATLAB SCRIPT - CONVERSION OF FE MESH TO OPENFOAM MESH ########################################################
######## Run the matlab code "mainblockMeshDict_NCF_from_XCT.m" to generate FE mesh
######## Change the DIRCECTORY name DIR to $thresholdWD in matlab scritp of "mainblockMeshDict_UD_from_XCT_parallel.m"
######## Specify the number of processor division to run the OpenFOAM code and devide equivalently distribution accordingly along X, Y and Z direction

# start=$(date +%s)

# matlab.exe -r -wait "run('C:\\Users\\debaa\\Desktop\SoftwareXPaperGitHub\Permeability\CodeBlockMeshMatlab\\mainblockMeshDict_UD_from_XCT_parallel'); exit;"

# end=$(date +%s)
# echo "Elapsed Time: $(($end-$start)) seconds"


####################################################################################################################################
#################### OPENFOAM BLOCKMESH AND PATCH CREATION #########################################################################
#################### Create blockMesh and patches of each side of the individual blocks ############################################
##### Enter into the specific directory while running the openfoam simulation from $thresholdWD
cd $parentdir/$thresholdWD
pwd
echo "I am here inside smaller block of each slices"

# for((k=1; k<=$numZlayers; k++));	do
# 	for((i=1; i<=$numSlice; i++));	do

# 		cd $parentdir/$thresholdWD
# 		pwd

# 		if [ -d "$parentdir/$thresholdWD/ofslice_$i\Z$k" ]; then
# 			echo "$parentdir/$thresholdWD/ofslice_$i\Z$k exists."
# 			rm -rf $parentdir/$thresholdWD/ofslice_$i\Z$k
# 		fi
# 		mkdir -p $parentdir/$thresholdWD/ofslice_$i\Z$k
		
# 		cp -r $parentdir/$thresholdWD/SLICE_$i\Z$k/constant $parentdir/$thresholdWD/ofslice_$i\Z$k
# 		cp -r $parentdir/$thresholdWD/SLICE_$i\Z$k/system $parentdir/$thresholdWD/ofslice_$i\Z$k

# 		cp -r $parentdir/$thresholdWD/0.setup $parentdir/$thresholdWD/ofslice_$i\Z$k/0
		
# 		cp $parentdir/$thresholdWD/system.setup/controlDict $parentdir/$thresholdWD/ofslice_$i\Z$k/system/
# 		cp $parentdir/$thresholdWD/system.setup/fvSolution $parentdir/$thresholdWD/ofslice_$i\Z$k/system/
# 		cp $parentdir/$thresholdWD/system.setup/fvSchemes $parentdir/$thresholdWD/ofslice_$i\Z$k/system/

# 		echo $parentdir/$thresholdWD
# 		cd $parentdir/$thresholdWD/ofslice_$i\Z$k
# 		blockMesh
# 		createPatch -overwrite
# 		touch ofslice_$i\Z$k.foam
# 		echo $parentdir/$thresholdWD
# 	done
# done

cd $parentdir/$thresholdWD
pwd
echo "I am here in the " $parentdir/$thresholdWD 'to create merge the small block' 

########################## MERGE the small block to create a large doamin with connected interfaces

# for((k=1; k<=$numZlayers; k++));	do
# 	for((i=1; i<=$numSlice; i++));	do
# 		mergeMeshes -overwrite ofslice_1Z1 ofslice_$i\Z$k
# 	done
# done



##### Copy the merge file into a combined file containing only one blockMesh of the entire blocks
FILE_u=combined_slice
# if [ -d "$parentdir/$thresholdWD/$FILE_u" ]; then
# 	echo "$parentdir/$thresholdWD/$FILE_u exists."
# 	rm -rf $parentdir/$thresholdWD/$FILE_u
# fi

# mkdir -p $parentdir/$thresholdWD/$FILE_u

# cp -r $parentdir/$thresholdWD/ofslice_1Z1/constant $parentdir/$thresholdWD/$FILE_u

# cp -r system.setup $parentdir/$thresholdWD/$FILE_u/system

# cp -r 0.setup $parentdir/$thresholdWD/$FILE_u/0

# cp -r constant.setup/transportProperties $parentdir/$thresholdWD/$FILE_u/constant
# cp -r constant.setup/turbulenceProperties $parentdir/$thresholdWD/$FILE_u/constant

# cd $parentdir
# cp combiLocalPorosityProp.py $parentdir/$thresholdWD/combiLocalPorosityProp.py

# cd $parentdir/$thresholdWD/$FILE_u

# ##### Create the intrface patch for combined slices
# createPatch -overwrite

# ##### Create a faceSet for combined slices 
# ##### This faceSet will be used to allocated into specific processor while runing the simulaion in parallel
# topoSet


##########################################################################################################################
######## The python script has been used to combine all the porosity properites from individual SLICE's to create a giant porosityProperties file of combined FOAM simulation
# cd $parentdir/$thresholdWD

# python combiLocalPorosityProp.py $numSlice $numZlayers

cd $parentdir/$thresholdWD

#### Remove the blockMesh file of smaller block 
# for((k=1; k<=$numZlayers; k++));	do
# 	for((i=1; i<=$numSlice; i++));	do
# 		rm -rf $parentdir/$thresholdWD/ofslice_$i\Z$k
# 	done
# done

for((KK=2; KK<=3; KK++));	do

	echo $KK

	if [ -d "$parentdir/$thresholdWD/Perm$KK" ]; then
		echo "$parentdir/$thresholdWD/Perm$KK exists."
		rm -rf $parentdir/$thresholdWD/Perm$KK
	fi
	
	mkdir -p $parentdir/$thresholdWD/Perm$KK

	cp -r $parentdir/$thresholdWD/$FILE_u/* $parentdir/$thresholdWD/Perm$KK

	cp -r $parentdir/0.setup/p$KK $parentdir/$thresholdWD/Perm$KK/0/p
	cp -r $parentdir/0.setup/U$KK $parentdir/$thresholdWD/Perm$KK/0/U

	#### These are the run cases from previous simulation
	#### remove these before new simulation
	cd $parentdir/$thresholdWD/Perm$KK
	rm -rf processor*
	#rm -rf 30
	#rm -rf 60
	#rm -rf 90
	#rm -rf 120
	# #rm -rf postProcessing

	# ##### Decompose the new file 
	decomposePar
	pwd

	# cd $parentdir

	for((i=0; i<=$[nprocs-1]; i++));	do
		cp -r $parentdir/$thresholdWD/$FILE_u/constant/porosityProperties_K$KK $parentdir/$thresholdWD/Perm$KK/processor$i/constant/porosityProperties
		cp -r $parentdir/$thresholdWD/$FILE_u/constant/porosityProperties_K$KK $parentdir/$thresholdWD/Perm$KK/constant/porosityProperties
		cp -r $parentdir/$thresholdWD/$FILE_u/constant/transportProperties $parentdir/$thresholdWD/Perm$KK/processor$i/constant
		cp -r $parentdir/$thresholdWD/$FILE_u/constant/turbulenceProperties $parentdir/$thresholdWD/Perm$KK/processor$i/constant
	done

	
	# mpirun -np $nprocs porousSimpleFoam -parallel 
	# reconstructPar

	#### If this works does not work try running with the following porousSimpleFoam model in parallel and there is no need to run the reconstructPar
	mpirun -np $nprocs porousSimpleFoam

	touch combinedK$KK.foam
	
	cp $parentdir/permeability.py $parentdir/$thresholdWD/Perm$KK/permeability.py
	if [ $KK -eq 1 ]
	 	then
		postProcess -func 'flowRatePatch(name=sidesX2)' -latestTime
		python permeability.py $KK sidesX2 $Vf $NX $NY $NZ $SKIP
		rm -rf processor*
	fi

	if [ $KK -eq 2 ]
		then
		postProcess -func 'flowRatePatch(name=sidesY2)' -latestTime
		python permeability.py $KK sidesY2 $Vf $NX $NY $NZ $SKIP
		rm -rf processor*
	fi

	if [ $KK -eq 3 ]
  		then
		postProcess -func 'flowRatePatch(name=sidesZ2)' -latestTime
		python permeability.py $KK sidesZ2 $Vf $NX $NY $NZ $SKIP
		rm -rf processor*
	fi


	# echo "Peremeability prediciton is done."
	echo "Double check the fow direction to fiber direction so that the K1, K2 and K3 truly represent the permeability"

done

##### Estimated time to run the entire workflow 

# end=$(date +%s)
# echo "Elapsed Time: $(($end-$start)) seconds"


