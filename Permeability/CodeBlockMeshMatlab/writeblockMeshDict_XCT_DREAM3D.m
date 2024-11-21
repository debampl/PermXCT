%% Writing the blockMeshDict file for openFoam

function writeblockMeshDict_XCT_DREAM3D(nGrain, A, Grain, X0Elm, X1Elm, Y0Elm, Y1Elm, Z0Elm, Z1Elm, fileID)

% fileID = fopen('blockMeshDict','w');
fprintf(fileID,'%s\n','/*--------------------------------*- C++ -*----------------------------------*\');
fprintf(fileID,'%s\n','| =========                 |                                                 |');
fprintf(fileID,'%s\n','| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |');
fprintf(fileID,'%s\n','|  \\    /   O peration     | Version:  v1912                                 |');
fprintf(fileID,'%s\n','|   \\  /    A nd           | Website:  www.openfoam.com                      |');
fprintf(fileID,'%s\n','|    \\/     M anipulation  |                                                 |');
fprintf(fileID,'%s\n','\*---------------------------------------------------------------------------*/');
fprintf(fileID,'%s\n','FoamFile');
fprintf(fileID,'%s\n','{');
fprintf(fileID,'%s\n','    version     2.0;');
fprintf(fileID,'%s\n','    format      ascii;');
fprintf(fileID,'%s\n','    class       dictionary;');
fprintf(fileID,'%s\n','    object      blockMeshDict;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','// *************************DEB BLOCKMESHDICT******************************************* //');
fprintf(fileID,'\n');

fprintf(fileID,'%s\n','convertToMeters 13.96607e-6;'); % convert unit [convertToMeters]
fprintf(fileID,'\n');

% Define vertices
fprintf(fileID,'%s\n','vertices');
fprintf(fileID,'%c\n','(');
  
    for i =1:numel(A(:,1))
    fprintf(fileID,'%s%2.2f %2.2f %2.4f%s\n','    (', A(i,1), A(i,2), A(i,3), ')');
    end
    
fprintf(fileID,'%s\n',');');
fprintf(fileID,'%c\n','');

% Define the blocks
fprintf(fileID,'%s\n','blocks');
fprintf(fileID,'%c\n','(');

%% Writing elements of Matrix
% % Number of grid division for matrix
% ndx = 1;
% ndy = 1;
% ndz = 1;
% 
% for i =1:numel(ME(:,1))
%               
%     fprintf(fileID,'%s %s%d %d %d %d %d %d %d %d%s %s %s%d %d %d%s %s %s%d %d %d%s\n', ...
%     '    hex','(',ME(i,1),ME(i,2),ME(i,3),ME(i,4),ME(i,5),ME(i,6),ME(i,7),ME(i,8), ...
%     ')','Matrix','(',ndx,ndy,ndz,')','simpleGrading','(',1,1,1,')'); 
%     
% end

%% Writing elements of Yarn
% Number of grid division for Yarn
ndx = 1;
ndy = 1;
ndz = 1;

for y = 1:nGrain
 
    for i =1:numel(Grain(y).E(:,1))
        
    fprintf(fileID,'%s %s%d %d %d %d %d %d %d %d%s %s %s%d %d %d%s %s %s%d %d %d%s\n', ...
    '    hex','(',Grain(y).E(i,1),Grain(y).E(i,2),Grain(y).E(i,3),...
    Grain(y).E(i,4),Grain(y).E(i,5),Grain(y).E(i,6), Grain(y).E(i,7),...
    Grain(y).E(i,8),')',Grain(y).NAME,'(', ndx,ndy,ndz,')','simpleGrading','(',1,1,1,')'); 

    end
 
end

fprintf(fileID,'%s\n',');');
fprintf(fileID,'%c\n','');

% Define edges
fprintf(fileID,'%s\n','edges');
fprintf(fileID,'%c\n','(');
fprintf(fileID,'%s\n',');');
fprintf(fileID,'%c\n','');

%% Define boundary

fprintf(fileID,'%s\n','boundary');
fprintf(fileID,'%c\n','(');

%% SIDE X1 PATCH
fprintf(fileID,'%s\n','    sidesX1');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(X0Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',X0Elm(i,1),...
        X0Elm(i,2),X0Elm(i,3),X0Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%% SIDE X2 PATCH
fprintf(fileID,'%s\n','    sidesX2');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(X1Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',X1Elm(i,1),...
        X1Elm(i,2),X1Elm(i,3),X1Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%% SIDE Y1 PATCH
fprintf(fileID,'%s\n','    sidesY1');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(Y0Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',Y0Elm(i,1),...
        Y0Elm(i,2),Y0Elm(i,3),Y0Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%% SIDE Y2 PATCH
fprintf(fileID,'%s\n','    sidesY2');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(Y1Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',Y1Elm(i,1),...
        Y1Elm(i,2),Y1Elm(i,3),Y1Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%% SIDE Z1 PATCH
fprintf(fileID,'%s\n','    sidesZ1');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(Z0Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',Z0Elm(i,1),...
        Z0Elm(i,2),Z0Elm(i,3),Z0Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%% SIDE Z2 PATCH
fprintf(fileID,'%s\n','    sidesZ2');
fprintf(fileID,'%s\n','    {');
fprintf(fileID,'%s\n','        type patch;');
fprintf(fileID,'%s\n','        faces');
fprintf(fileID,'%s\n', '        (');
for i =1:numel(Z1Elm(:,1))
    fprintf(fileID,'%s%d %d %d %d%s\n','            (',Z1Elm(i,1),...
        Z1Elm(i,2),Z1Elm(i,3),Z1Elm(i,4),')');
end
fprintf(fileID,'%s\n', '        );');
fprintf(fileID,'%s\n','    }');

%%
fprintf(fileID,'%s\n',');');
fprintf(fileID,'%c\n','');

%% Define mergePatchPairs
fprintf(fileID,'%s\n','mergePatchPairs');
fprintf(fileID,'%c\n','(');
fprintf(fileID,'%s\n',');');
fprintf(fileID,'%c\n','');


fprintf(fileID,'%c\n','');
fprintf(fileID,'%c\n','');
fprintf(fileID,'%s\n','// ************************************************************************* //');
end
