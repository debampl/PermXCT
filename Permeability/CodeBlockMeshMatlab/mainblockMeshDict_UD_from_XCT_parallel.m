%  OpenFOAM specific premeability model 
%  Generation of blockMeshDict and porosityProperties for any type of
%  fabric generated using DREAM3D from XCT scan.
%  The voxel contains multiple grain distribution
%  Debabrata Adhikari 14/11/2023
%  MPP, DTU-Construct, Lyngby, Denmark
%%
clear all;
clc;

% tic   % Calculate run time

DIR = ['C:\Users\debaa\Desktop\SoftwareXPaperGitHub\Permeability\'...
    +'Dom148x228x36\Thresold36784skippVox4\'];

ncol = 4; % Number of slice division in Z direction
nrow = 4; % Number of slice division in Y direction
nlevel = 4; % Number of level of slice division in X direction (Dream3D has rotated the XZ plane to ZX around the Y axis)

nProcs = 16;
nPdiv = [2, 2, 4]; %% Choose the nPdiv in a way such that nPdiv(1)*nPdiv(2)*nPdiv(3) = nprocs  

delete(gcp("nocreate"))
parpool
tic
for xlev=1:nlevel
%     xlev = 1;
    parfor slid=1:nrow*ncol
       createOpenFOAMmeshParallel(DIR, ncol, nrow, nlevel, slid, xlev)
   end
end

meshCreationElapsedTime = toc

delete(gcp("nocreate"))

tic
%% Writing the createPatchDict file for the interfaces in combined slices

combiFILE_DIR = strcat(DIR,'\system.setup');

combi_patchDict = fullfile(combiFILE_DIR,'createPatchDict');
fprintf("I am entering the writng createPatchDict file for combined interfaces\n");
combiFile = fopen(combi_patchDict,'w');
writeCreatePatchDict_combinedSlices(combiFile, ncol, nrow, nlevel);
fclose(combiFile); 
fprintf("I have completed writng createPatchDict for the interface in combined slices\n");

%% Writing the topoSetDict file for the interfaces in combined slices

combiTopoFILE_DIR = strcat(DIR,'\system.setup');
faceSet = {};% = 'faceSetList';

combiTopoDict = fullfile(combiTopoFILE_DIR,'topoSetDict');
fprintf("I am entering the writng topoSetDict file for combined interfaces\n");
combiTopoFile = fopen(combiTopoDict,'w');
faceSet = writeTopoSetDict_combinedSlices(combiTopoFile, ncol, nrow, nlevel, faceSet);
fclose(combiTopoFile); 
fprintf("I have completed writng topoSetDict for the interface in combined slices\n");

%% Writing the decomposeParDict to distribute the mesh into nPorcs and keep all the interface in a single processes

decomposePar_DIR = strcat(DIR,'\system.setup');

decompParDict = fullfile(decomposePar_DIR,'decomposeParDict');
fprintf("I am entering decomposeParDict file edit\n");
decompParFile = fopen(decompParDict,'w');
writeDecomposeParDict(decompParFile, ncol, nrow, nPdiv, nlevel, faceSet);
fclose(decompParFile); 
fprintf("I have completed writng decomposeParDict file\n");

%% Writing the pressure BC to 0.setup file with all the interface

pressure_DIR = strcat(DIR,'\0.setup');
for K=1:3
    pressureFName = sprintf('p%d',K);
    pressureDict = fullfile(pressure_DIR, pressureFName);
    fprintf("I am entering pressure BC file edit\n");
    pressureFile = fopen(pressureDict,'w');
    writePressureBC_combinedSlices(pressureFile, ncol, nrow, nlevel, K);
    fclose(pressureFile); 
end
fprintf("I have completed writng pressure BC file\n");

%% Writing the velocity BC to 0.setup file with all the interface

velocity_DIR = strcat(DIR,'\0.setup');
for K=1:3
    velocityFName = sprintf('U%d',K);
    velocityDict = fullfile(velocity_DIR, velocityFName);
    fprintf("I am entering velocity BC file edit\n");
    veloctiyFile = fopen(velocityDict,'w');
    writeVeloctiyBC_combinedSlices(veloctiyFile, ncol, nrow, nlevel, K);
    fclose(veloctiyFile); 
end
fprintf("I have completed writng velocity BC file\n");

totalElapsedTime = toc + meshCreationElapsedTime  % Calculate run time

% exit