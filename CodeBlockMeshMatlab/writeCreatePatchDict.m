%% Writing the createPatchDict file for individual slices in openFoam

function writeCreatePatchDict(fileID, ncol, nrow, slice_id, xlev, nlevel)

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

%% Inteface in Z surface _ co-ordinate direction as in XY plane (col,row) 

for i =1:nrow*ncol
    if(mod(i,ncol) ~= 0)
        if(slice_id == i)
            fprintf(fileID,'    {\n');
            fprintf(fileID,'        name slice%dZ%d_sideZ2_ami;\n',slice_id,xlev);
            fprintf(fileID,'\n');
            fprintf(fileID,'        patchInfo\n');
            fprintf(fileID,'        {\n');
            fprintf(fileID,'            type wall;\n');
            fprintf(fileID,'        }\n');
            fprintf(fileID,'        constructFrom patches;\n');
            fprintf(fileID,'        patches (sidesZ2);\n');
            fprintf(fileID,'    }\n');
            fprintf(fileID,'\n');      
        end
        if(slice_id == i+1)
            fprintf(fileID,'    {\n');
            fprintf(fileID,'        name slice%dZ%d_sideZ1_ami;\n',slice_id,xlev);
            fprintf(fileID,'\n');
            fprintf(fileID,'        patchInfo\n');
            fprintf(fileID,'        {\n');
            fprintf(fileID,'            type wall;\n');
            fprintf(fileID,'        }\n');
            fprintf(fileID,'        constructFrom patches;\n');
            fprintf(fileID,'        patches (sidesZ1);\n');
            fprintf(fileID,'    }\n');
            fprintf(fileID,'\n');      
        end

    end
end

%% Inteface in Y surface _ co-ordinate direction as in XZ plane (col,row)

for i =1:(nrow-1)*ncol
    %interfaceY = [i, i+4];
    if(slice_id == i)
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name slice%dZ%d_sideY2_ami;\n',slice_id,xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type wall;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (sidesY2);\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end
    
    if(slice_id == i+ncol)
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name slice%dZ%d_sideY1_ami;\n',slice_id,xlev);
        fprintf(fileID,'\n');
        fprintf(fileID,'        patchInfo\n');
        fprintf(fileID,'        {\n');
        fprintf(fileID,'            type wall;\n');
        fprintf(fileID,'        }\n');
        fprintf(fileID,'        constructFrom patches;\n');
        fprintf(fileID,'        patches (sidesY1);\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end
end

%% Inteface in X surface _ co-ordinate direction as in XY plane (col,row)
% Interface between X-layers of slices in ZY plane to next.
if (xlev==1)
    fprintf(fileID,'    {\n');
    fprintf(fileID,'        name slice%dZ%d_sideX2_ami;\n',slice_id,xlev);
    fprintf(fileID,'\n');
    fprintf(fileID,'        patchInfo\n');
    fprintf(fileID,'        {\n');
    fprintf(fileID,'            type wall;\n');
    fprintf(fileID,'        }\n');
    fprintf(fileID,'        constructFrom patches;\n');
    fprintf(fileID,'        patches (sidesX2);\n');
    fprintf(fileID,'    }\n');
    fprintf(fileID,'\n');
end

if (xlev==nlevel)
    fprintf(fileID,'    {\n');
    fprintf(fileID,'        name slice%dZ%d_sideX1_ami;\n',slice_id,xlev);
    fprintf(fileID,'\n');
    fprintf(fileID,'        patchInfo\n');
    fprintf(fileID,'        {\n');
    fprintf(fileID,'            type wall;\n');
    fprintf(fileID,'        }\n');
    fprintf(fileID,'        constructFrom patches;\n');
    fprintf(fileID,'        patches (sidesX1);\n');
    fprintf(fileID,'    }\n');
    fprintf(fileID,'\n');
end

if ((xlev ~= 1) && (xlev~=nlevel))
    fprintf(fileID,'    {\n');
    fprintf(fileID,'        name slice%dZ%d_sideX1_ami;\n',slice_id,xlev);
    fprintf(fileID,'\n');
    fprintf(fileID,'        patchInfo\n');
    fprintf(fileID,'        {\n');
    fprintf(fileID,'            type wall;\n');
    fprintf(fileID,'        }\n');
    fprintf(fileID,'        constructFrom patches;\n');
    fprintf(fileID,'        patches (sidesX1);\n');
    fprintf(fileID,'    }\n');
    fprintf(fileID,'\n');

    fprintf(fileID,'    {\n');
    fprintf(fileID,'        name slice%dZ%d_sideX2_ami;\n',slice_id,xlev);
    fprintf(fileID,'\n');
    fprintf(fileID,'        patchInfo\n');
    fprintf(fileID,'        {\n');
    fprintf(fileID,'            type wall;\n');
    fprintf(fileID,'        }\n');
    fprintf(fileID,'        constructFrom patches;\n');
    fprintf(fileID,'        patches (sidesX2);\n');
    fprintf(fileID,'    }\n');
    fprintf(fileID,'\n');
end
 

fprintf(fileID,');\n');
fprintf(fileID,'\n');
fprintf(fileID,'// ******************************************** //\n');
% fclose(fileID);
end

