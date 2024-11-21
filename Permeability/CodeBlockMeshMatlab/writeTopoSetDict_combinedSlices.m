%% Writing the topoSetDict file to keep all the interface in a same place during openFoam simulation

function [faceSet] = writeTopoSetDict_combinedSlices(fileID, ncol, nrow, nlevel, faceSet)

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
fprintf(fileID,'%s\n','    object      topoSetDict;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','//*************************UPDATE TOPO STE DICT *****************************//');
fprintf(fileID,'%s\n','//*** Create faceSet for AMI patches to avoid having processor boundaries cross them ***//');
fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'actions\n');
fprintf(fileID,'(\n');
fprintf(fileID,'\n');


faceCount = 1;

%% Inteface in Z surface _ co-ordinate direction as in XY plane (col,row) 
for zl=1:nlevel
    for i =1:nrow*ncol
        if(mod(i,ncol) ~= 0)
    
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name f%dZ%d;\n',zl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action new;\n');
        faceSet{faceCount} = ['f', num2str(zl),'Z',num2str(i)];
%         if((i == 1))
%             fprintf(fileID,'        action new;\n');
%             faceSet{zl} = ['f', num2str(zl),'Z'];
%         else
%             fprintf(fileID,'        action add;\n');
%         end
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%d%dZ%d";\n',i, i+1, zl);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name f%dZ%d;\n',zl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action add;\n');
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%d%dZ%d";\n',i+1, i, zl);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        faceCount = faceCount + 1;
        end
    end
end
    faceCount = faceCount -1
%% Inteface in Y surface _ co-ordinate direction as in XZ plane (col,row)
for yl=1:nlevel    
    for i =1:(nrow-1)*ncol
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name f%dY%d;\n',yl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action new;\n');
        faceSet{faceCount} = ['f', num2str(yl),'Y',num2str(i)];
%         if((i == 1))
%             fprintf(fileID,'        action new;\n');
%             faceSet{nlevel+yl} = ['f', num2str(yl),'Y'];
%         else
%             fprintf(fileID,'        action add;\n');
%         end
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%d%dY%d";\n',i, i+ncol, yl);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');        
        fprintf(fileID,'        name f%dY%d;\n',yl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action add;\n');
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%d%dY%d";\n',i+ncol, i, yl);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        faceCount = faceCount +1;
    end
end
    faceCount = faceCount -1
%% Inteface in X surface _ co-ordinate direction as in YZ plane (col,row)
for xl=1:(nlevel-1)
    for i =1:nrow*ncol
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name f%dX%d;\n',xl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action new;\n');
        faceSet{faceCount} = ['f', num2str(xl),'X', num2str(i)];
%         if((i == 1))
%             fprintf(fileID,'        action new;\n');
%             faceSet{2*nlevel+nrow*ncol+xl} = ['f', num2str(xl),'X'];
%         else
%             fprintf(fileID,'        action add;\n');
%         end
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%dX%d%d";\n',i, xl, xl+1);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        name f%dX%d;\n',xl,i);
        fprintf(fileID,'        type faceSet;\n');
        fprintf(fileID,'        action add;\n');
        fprintf(fileID,'        source patchToFace;\n');
        fprintf(fileID,'        sourceInfo\n'); 
        fprintf(fileID,'        {\n');
        fprintf(fileID,'        patch "interface%dX%d%d";\n',i, xl+1, xl);
        fprintf(fileID,'        }\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        faceCount = faceCount +1;
    end
end
    faceCount = faceCount -1
fprintf(fileID,');\n');
fprintf(fileID,'\n');
fprintf(fileID,'// ******************************************** //\n');
% fclose(fileID);
end

