%% Writing the createPatchDict file for combined slices in openFoam

function writeCreatePatchDict_combinedSlices(fileID, ncol, nrow, nlevel)

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
fprintf(fileID,'%s\n','    object      createPatchDict;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','// *************************UPDATE CREATE PATCH DICT ***************************** //');
fprintf(fileID,'\n');

fprintf(fileID,'pointSync true;\n');
fprintf(fileID,'\n');
fprintf(fileID,'// Patches to create.\n');
fprintf(fileID,'\n');
fprintf(fileID,'patches\n');
fprintf(fileID,'(\n');
fprintf(fileID,'\n');


for xlev=1:nlevel
    %% Inteface in Z surface _ co-ordinate direction as in ZY plane (col,row) 
    for i =1:nrow*ncol
        if(mod(i,ncol) ~= 0)
    
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%d%dZ%d;\n',i, i+1,xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%d%dZ%d;\n',i+1, i, xlev);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideZ%d_ami);\n', i, xlev, 2);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%d%dZ%d;\n',i+1, i, xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%d%dZ%d;\n',i, i+1, xlev);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideZ%d_ami);\n', i+1, xlev, 1);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    
        end
    end
    
    %% Inteface in Y surface _ co-ordinate direction as in ZY plane (col,row)
    
    for i =1:(nrow-1)*ncol
        %interfaceY = [i, i+4];
    
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%d%dY%d;\n',i, i+ncol,xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%d%dY%d;\n',i+ncol, i, xlev);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideY%d_ami);\n', i, xlev, 2);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%d%dY%d;\n',i+ncol, i, xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%d%dY%d;\n',i, i+ncol, xlev);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideY%d_ami);\n', i+ncol, xlev, 1);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end

    %% Inteface in X surface _ co-ordinate direction as in ZY plane (col,row) between layers
end

for xl=1:(nlevel-1)
    for i =1:nrow*ncol
    
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%dX%d%d;\n',i, xl, xl+1);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%dX%d%d;\n',i, xl+1, xl);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideX%d_ami);\n', i, xl, 2);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name interface%dX%d%d;\n',i, xl+1, xl);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type cyclicAMI;\n');
        fprintf(fileID,'            inGroups 1(cyclicAMI);\n');
        fprintf(fileID,'            neighbourPatch  interface%dX%d%d;\n',i, xl, xl+1);
        fprintf(fileID,'            matchTolerance  0.0001;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (slice%dZ%d_sideX%d_ami);\n', i, xl+1, 1);
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end

end



fprintf(fileID,');\n');
fprintf(fileID,'\n');
fprintf(fileID,'// ******************************************** //\n');
% fclose(fileID);
end

