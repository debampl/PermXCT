%% Writing the topoSetDict file to keep all the interface in a same place during openFoam simulation

function writePressureBC_combinedSlices(fileID, ncol, nrow, nlevel, K)

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
fprintf(fileID,'%s\n','    class       volScalarField;');
fprintf(fileID,'%s\n','    object      p;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','//*************************UPDATE TOPO STE DICT *****************************//');
fprintf(fileID,'%s\n','//*** Create faceSet for AMI patches to avoid having processor boundaries cross them ***//');
fprintf(fileID,'\n');
fprintf(fileID,'\n');
fprintf(fileID,'dimensions      [0 2 -2 0 0 0 0];\n');
fprintf(fileID,'\n');
fprintf(fileID,'internalField      uniform 0;\n');
fprintf(fileID,'\n');
fprintf(fileID, 'boundaryField\n');
fprintf(fileID,'{\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesZ1\n');
fprintf(fileID,'    {\n');
if (K == 3)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.1;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesZ2\n');
fprintf(fileID,'    {\n');
if (K == 3)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.001;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
    fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesX1\n');
fprintf(fileID,'    {\n');
if (K == 1)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.1;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesX2\n');
fprintf(fileID,'    {\n');
if (K == 1)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.001;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesY1\n');
fprintf(fileID,'    {\n');
if (K == 2)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.1;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

fprintf(fileID,'    sidesY2\n');
fprintf(fileID,'    {\n');
if (K == 2)
    fprintf(fileID,'        type fixedValue;\n');
    fprintf(fileID,'        value uniform 0.001;\n');
    K
else
    fprintf(fileID,'        type zeroGradient;\n');
    K
end
fprintf(fileID,'    }\n');
fprintf(fileID,'\n');

%% Inteface in Z surface _ co-ordinate direction as in ZY plane (col,row) 
for xlev=1:nlevel
    for i =1:nrow*ncol
        if(mod(i,ncol) ~= 0)
        fprintf(fileID,'    interface%d%dZ%d\n',i, i+1, xlev);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        type cyclicAMI;\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    interface%d%dZ%d\n',i+1, i, xlev);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        type cyclicAMI;\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    
        end
    end
    
    %% Inteface in Y surface _ co-ordinate direction as in ZY plane (col,row)
    
    for i =1:(nrow-1)*ncol
        %interfaceY = [i, i+4];
        fprintf(fileID,'    interface%d%dY%d\n',i, i+ncol, xlev);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'          type cyclicAMI;\n');
        fprintf(fileID,'     }\n')
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    interface%d%dY%d\n',i+ncol, i, xlev);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        type cyclicAMI;\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end
end

for xl=1:(nlevel-1)
    for i =1:nrow*ncol
        fprintf(fileID,'    interface%dX%d%d\n',i, xl, xl+1);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        type cyclicAMI;\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
        
        fprintf(fileID,'    interface%dX%d%d\n',i, xl+1, xl);
        fprintf(fileID,'    {\n');
        fprintf(fileID,'        type cyclicAMI;\n');
        fprintf(fileID,'    }\n');
        fprintf(fileID,'\n');
    end
end

fprintf(fileID,'};\n');
fprintf(fileID,'\n');
fprintf(fileID,'// ******************************************** //\n');
% fclose(fileID);
end

