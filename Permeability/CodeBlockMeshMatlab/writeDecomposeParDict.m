%% Writing the decomposeParDict
% assign the number of prcessor and cell division in (X,Y,Z) direction on
% the combined mesh. This is not necessarily be the same as slice division.

function writeDecomposeParDict(fileID, ncol, nrow, nPdiv, nlevel, faceSet)

% fileID = fopen(DIR_porosity,'w');
fprintf(fileID,'%s\n','/*--------------------------------*- C++ -*----------------------------------*\');
fprintf(fileID,'%s\n','| =========                 |                                                 |');
fprintf(fileID,'%s\n','| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |');
fprintf(fileID,'%s\n','|  \\    /   O peration     | Website:  www.openfoam.com                      |');
fprintf(fileID,'%s\n','|   \\  /    A nd           | Version:  7                                     |');
fprintf(fileID,'%s\n','|    \\/     M anipulation  |                                                 |');
fprintf(fileID,'%s\n','\*---------------------------------------------------------------------------*/');
fprintf(fileID,'%s\n','FoamFile');
fprintf(fileID,'%s\n','{');
fprintf(fileID,'%s\n','    version     2.0;');
fprintf(fileID,'%s\n','    format      ascii;');
fprintf(fileID,'%s\n','    class       dictionary;');
fprintf(fileID,'%s\n','    location    "system";');
fprintf(fileID,'%s\n','    object      decomposeParDict;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','//*************************UPDATE TOPO STE DICT *****************************//');
fprintf(fileID,'%s\n','//*** Assign the processor division and restrict the all the interface simulation to perform in a single patch ***//\n');
fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'numberOfSubdomains      %d;     // # of CPU cores\n', prod(nPdiv));
fprintf(fileID,'\n');
fprintf(fileID,'method          simple;\n');
fprintf(fileID,'\n');

fprintf(fileID,'coeffs\n');
fprintf(fileID,'{\n');

fprintf(fileID,['    n          ( %d %d %d );    // simple division in XYZ ...' ...
    'drirection must be equals to the number of total core\n'], nPdiv(1), nPdiv(2), nPdiv(3));
fprintf(fileID,'    delta          0.001;\n');
fprintf(fileID,'}\n');

fprintf(fileID,'\n');
fprintf(fileID,'constraints\n');
fprintf(fileID,'{\n');
fprintf(fileID,'\n');
fprintf(fileID,'    // Keep owner and neighbour of baffles on the same processor\n');
fprintf(fileID,'    // (ie, keep it detectable as a baffles).\n');
fprintf(fileID,'    // Baffles are two boundary face sharing the same points\n');
fprintf(fileID,'    baffles\n');
fprintf(fileID,'    {\n');
fprintf(fileID,'        type        preserveBaffles;\n');
fprintf(fileID,'        enabled     false;\n');
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');
fprintf(fileID,'    // Keep owned and neighbour on same processor for faces in zones\n');
fprintf(fileID,'    faces\n');
fprintf(fileID,'    {\n');
fprintf(fileID,'        type        preserveFaceZones;\n');
fprintf(fileID,'        zones       (".*");\n');
fprintf(fileID,'        enables     false;\n');
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');
fprintf(fileID,'    // Keep owner and neighbour on same processor for faces in patches\n');
fprintf(fileID,'    // (only makes sense for cyclic patches. Not subtbale for e.g.\n');
fprintf(fileID,'    // cyclicAMI since these are not coupled on the patch level.\n');
fprintf(fileID,'    // Use singleProcessorFaceSets for those.\n');
fprintf(fileID,'    patches\n');
fprintf(fileID,'    {\n');
fprintf(fileID,'        type        preservePatches;\n');
fprintf(fileID,'        patches     (');
for xlev=1:nlevel
    for i =1:nrow*ncol
        if(mod(i,ncol) ~= 0)
            fprintf(fileID,'interface%d%dZ%d interface%d%dZ%d\n                   ', i, i+1, xlev, i+1, i, xlev);
        end
    end
end
for xlev=1:nlevel
    for i =1:(nrow-1)*ncol
        fprintf(fileID,'interface%d%dY%d interface%d%dY%d\n                   ', i, i+ncol, xlev, i+ncol, i, xlev);
    end
end

for xl=1:(nlevel-1)
    for i =1:nrow*ncol
        fprintf(fileID,'interface%dX%d%d interface%dX%d%d\n                   ', i, xl, xl+1, i, xl+1, xl);
    end
end
fprintf(fileID,');\n');
fprintf(fileID,'        enables     flase;\n');
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');
fprintf(fileID,'    // Keep all of faceSet on a single processor. This puts all cells \n');
fprintf(fileID,'    // connected with a point, edge or face on the same processor.\n');
fprintf(fileID,'    // (just having face connected cells might not gurantee a balanced decomposition)\n');
fprintf(fileID,'    // This processor can be -1 (the decompositionMethod chooses the\n');
fprintf(fileID,'    // processor for a good load balance) or explicitly provided (upsets\n');
fprintf(fileID,'    // balance)\n');
fprintf(fileID,'    procs\n');
fprintf(fileID,'    {\n');
fprintf(fileID,'        type        singleProcessorFaceSets;\n');
fprintf(fileID,'        sets        (\n');
      for npFace = 1:numel(faceSet)
            fprintf(fileID,'                    (%s %d)\n',faceSet{npFace}, mod(npFace, prod(nPdiv)) );
      end
fprintf(fileID,'                    );\n');
fprintf(fileID,'        enables     true;\n');
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');
fprintf(fileID,'    // Decompose cells such that all cell originating from single cell \n');
fprintf(fileID,'    // end up on same processor\n');
fprintf(fileID,'    refinement\n');
fprintf(fileID,'    {\n');
fprintf(fileID,'        type        refinementHistory;\n');
fprintf(fileID,'        enables     false;\n');
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');
fprintf(fileID,'}\n');

fprintf(fileID,'\n');
fprintf(fileID,'// ******************************************** //\n');
% fclose(fileID);
end

