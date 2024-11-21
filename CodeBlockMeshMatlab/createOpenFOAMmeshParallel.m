function createOpenFOAMmeshParallel(DIR, ncol, nrow, nlevel, slid, xlev)
    
    slice_id = slid;
    
    sliceDir = sprintf('SLICE_%dZ%d',slice_id, xlev);
    
    FILE_DIR = strcat(DIR,sliceDir);
    
%     formatYran0 = 'Yarn0_%d'; % Define the cell set for individual yarn
%     formatYran90 = 'Yarn90_%d'; % Define the cell set for individual yarn
%     formatYranP45 = 'YarnP45_%d'; % Define the cell set for individual yarn
%     formatYranN45 = 'YarnN45_%d'; % Define the cell set for individual yarn
%     formatMatrix = 'Matrix_%d'; % Define the cell set for individual yarn
    
    % Type the identification string for Yarn
    fprintf("I am entering the reading inp files of elements, node and type\n");
    [NODE, ELM, Grain, nGrain] = readMatrixAndYarn_frmDREAM3D(FILE_DIR, slice_id, xlev);
    
    totalGrain = nGrain; 
    % Calculate the yarn permeability and assign to Warp Weft and Binder
    warpWeftPhi = 0.20; % Assuming the fibers are tightly packed in both the warp and weft yarn
    binderPhi = 0.20;
    R = (8.5e-6);
    squarePack = 1; 
    hexagonalPack = 2; % Assuming the fibers are arrange in heaxgonal pattern in both the warp and weft yarn
    
    [K1, K2] = Gebart_function(warpWeftPhi, R, 2);
    
%         K1 = 1e-10;
%         K2 = 2e-11;
%         K3 = 1e-17;
        
    % If the flow direction is align wiht the fiber direction, then take
    % Grain(i).K1, elase for the perpedicular direction take Grain(i).K2 and for
    % thickness direction flow take Grain(i).K2
    
    for i=1:totalGrain
        if (Grain(i).type == 0)
            Grain(i).NAME = sprintf('Yarn0_%d_slice%dZ%d', i,slice_id,xlev);
            Grain(i).phi = 1-0.740;
            Grain(i).K1 = num2str(warpWeftPhi*(1e-12)/K1); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K2 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K3 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
        end
        if (Grain(i).type == 1)
            Grain(i).NAME = sprintf('YarnP45_%d_slice%dZ%d', i,slice_id,xlev);
            Grain(i).phi = 1-0.115;
            Grain(i).K1 = num2str(warpWeftPhi*(1e-12)/(K1*(cos(3*pi/4))^2 + K2*(sin(3*pi/4))^2)); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K2 = num2str(warpWeftPhi*(1e-12)/(K2*(cos(3*pi/4))^2 + K1*(sin(3*pi/4))^2)); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K3 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
        end
        if (Grain(i).type == 2)
            Grain(i).NAME = sprintf('YarnN45_%d_slice%dZ%d', i,slice_id,xlev);
            Grain(i).phi = 1-0.127;
            Grain(i).K1 = num2str(warpWeftPhi*(1e-12)/(K1*(cos(pi/4))^2 + K2*(sin(pi/4))^2)); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K2 = num2str(warpWeftPhi*(1e-12)/(K2*(cos(pi/4))^2 + K1*(sin(pi/4))^2)); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K3 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
        end
        if (Grain(i).type == 3)
            Grain(i).NAME = sprintf('Yarn90_%d_slice%dZ%d', i,slice_id,xlev);
            Grain(i).phi = 1-0.017;
            Grain(i).K1 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K2 = num2str(warpWeftPhi*(1e-12)/K1); % co-efficient d = 1/K for the Darcy model in OpenFOAM
            Grain(i).K3 = num2str(warpWeftPhi*(1e-12)/K2); % co-efficient d = 1/K for the Darcy model in OpenFOAM
        end
        if (Grain(i).type == 4)
            Grain(i).NAME = sprintf('Matrix_%d_slice%dZ%d', i,slice_id,xlev);
        end
    end
    
    % write porosity properties to porosityProperties file
    DIR_const = strcat(FILE_DIR,'\constant');
    for K = 1:3 
        porosityName = sprintf('porosityProperties_K%d',K);
        DIR_porosity = fullfile(DIR_const,porosityName);
        writporosityProperties_XCT_DREAM3D(totalGrain, Grain, DIR_porosity, K, slice_id, xlev);
    end
    
    % Node co-ordinate
    nodex = NODE{1,3};
    nodey = NODE{1,5};
    nodez = NODE{1,7};
     
    A = [nodex, nodey, nodez];
     
    % Domain wall boundary
    minX = min(nodex);  %min x
    maxX = max(nodex);  %max x
    minY = min(nodey);  %min y
    maxY = max(nodey);  %max y
    minZ = min(nodez);  %min y
    maxZ = max(nodez);  %max y
    
    % Element connectivity
     elmid = ELM{1,1};
     elmA1 = ELM{1,3};
     elmA2 = ELM{1,5};
     elmA3 = ELM{1,7};
     elmA4 = ELM{1,9};
     elmB1 = ELM{1,11};
     elmB2 = ELM{1,13};
     elmB3 = ELM{1,15};
     elmB4 = ELM{1,17};
      
    % Element and node co-ordinate re-ordering
    E = zeros(numel(elmid),8);
    m = 1;  % index for matrix element addition
            
    % Node numbering and element ordering for YARN 
    for ny = 1:totalGrain 
      for j = 1:numel(Grain(ny).ELM)
        e = Grain(ny).ELM(j);
        E(m,:)= [elmA4(e), elmA1(e), elmA2(e), elmA3(e), elmB4(e), elmB1(e),...
               elmB2(e), elmB3(e)]-1;
        m = m+1; % Sequential addition of element to the Element set 
      end
     Grain(ny).E = E(( m - numel(Grain(ny).ELM) : m-1 ),:);   % Only Yarn element
    end
    
    % Define boundary patches
        x0 = 0;
        x1 = 0;
        y0 = 0;
        y1 = 0;
        z0 = 0;
        z1 = 0;
        X0s = 1;
        X1s = 1;
        Y0s = 1;
        Y1s = 1;
        Z0s = 1;
        Z1s = 1;
        PPx0 = zeros(4,1);
        PPx1 = zeros(4,1);
        PPy0 = zeros(4,1);
        PPy1 = zeros(4,1);
        PPz0 = zeros(4,1);
        PPz1 = zeros(4,1);
        sideX1Elm(1,:) = [1, 1, 1, 1];
        sideX2Elm(1,:) = [1, 1, 1, 1];
        sideY1Elm(1,:) = [1, 1, 1, 1];
        sideY2Elm(1,:) = [1, 1, 1, 1];
        sideZ1Elm(1,:) = [1, 1, 1, 1];
        sideZ2Elm(1,:) = [1, 1, 1, 1];
    
            P(1,:) = [1, 1, 1, 1, 2, 2, 2, 2];
    % Define boundary conditions 
    
    for e =1:numel(E(:,1))
       % e = 1;
        P = [E(e,1), E(e,2), E(e,3), E(e,4), E(e,5), E(e,6), E(e,7), E(e,8)] +1;
    
        for i = 1:8
            % Side X_half0 boundary
            if(A(P(i),1) == minX)     % x = -0.500 wall
                 x0 = x0+1;
                 PPx0(x0) = P(i);
            end
            
            % Side X_half1 boundary
            if(A(P(i),1) == maxX)      % x = 1.500 wall
                 x1 = x1+1;
                 PPx1(x1) = P(i);
            end
            
            % Side Y_half0 boundary
            if(A(P(i),2) == minY)     % y = -0.500 wall
                 y0 = y0+1;
                 PPy0(y0) = P(i);
            end
            
            % Side Y_half1 boundary
            if(A(P(i),2) == maxY)      % y = 2.500 wall
                 y1 = y1+1;
                 PPy1(y1) = P(i);
            end
            
            % Side Z_half0 boundary
            if(A(P(i),3) == minZ)     % Z = -0.500 wall
                 z0 = z0+1;
                 PPz0(z0) = P(i);
            end
            
            % Side Z_half1 boundary
            if(A(P(i),3) == maxZ)      % Z = 2.500 wall
                 z1 = z1+1;
                 PPz1(z1) = P(i);
            end
            
        end
        
        if (x0 == 4)
            sideX1Elm(X0s,:) = anticlockpointorder(A, 2, 3, PPx0(1), PPx0(2), PPx0(3), PPx0(4))-1;
            X0s = X0s +1;
        end
        
        if (x1 == 4)
            sideX2Elm(X1s,:) = anticlockpointorder(A, 2, 3, PPx1(1), PPx1(2), PPx1(3), PPx1(4))-1;
            X1s = X1s +1;
        end
        
        if (y0 == 4)
            sideY1Elm(Y0s,:) = anticlockpointorder(A, 1, 3, PPy0(1), PPy0(2), PPy0(3), PPy0(4))-1;
            Y0s = Y0s +1;
        end
        
        if (y1 == 4)
            sideY2Elm(Y1s,:) = anticlockpointorder(A, 1, 3, PPy1(1), PPy1(2), PPy1(3), PPy1(4))-1;
            Y1s = Y1s +1;
        end
        
        if (z0 == 4)
            sideZ1Elm(Z0s,:) = anticlockpointorder(A, 2, 1, PPz0(1), PPz0(2), PPz0(3), PPz0(4))-1;
            Z0s = Z0s +1;
        end
        
        if (z1 == 4)
            sideZ2Elm(Z1s,:) = anticlockpointorder(A, 2, 1, PPz1(1), PPz1(2), PPz1(3), PPz1(4))-1;
            Z1s = Z1s +1;
        end
        
         x0 = 0;
         x1 = 0;
         y0 = 0;
         y1 = 0;
         z0 = 0;
         z1 = 0;
         
    end
    
%   B = A;
    
    %% Writing the blockMeshDict file
    DIR_sys = strcat(FILE_DIR,'\system');
    DIR_blockMeshDict = fullfile(DIR_sys,'blockMeshDict');
    fprintf("I am entering the writng blockMesh file for slice %dZ%d \n", slice_id,xlev);
    fileID = fopen(DIR_blockMeshDict,'w');
    writeblockMeshDict_XCT_DREAM3D(totalGrain, A, Grain, sideX1Elm, sideX2Elm,...
        sideY1Elm, sideY2Elm, sideZ1Elm, sideZ2Elm, fileID);
    fclose(fileID); 
    fprintf("I have completed writng blockMesh file\n");
    
    
    
    %% Writing the createPatchDict file for individual slices
    
    DIR_patchDict = fullfile(DIR_sys,'createPatchDict');
    fprintf("I am entering the writng createPatchDict file\n");
    fileID = fopen(DIR_patchDict,'w');
    writeCreatePatchDict(fileID, ncol, nrow, slice_id, xlev, nlevel);
    fclose(fileID); 
    fprintf("I have completed writng createPatchDict for each slices\n");

end