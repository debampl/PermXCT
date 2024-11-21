%% Writing the blockMeshDict file for openFoam

function writporosityProperties_XCT_DREAM3D(nGrain, Grain, DIR_porosity, K, slice_id, xlev)
fprintf("I am entering the writing prosity file for K = %d\n", K);

fileID = fopen(DIR_porosity,'wt');
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
fprintf(fileID,'%s\n','    location    "constant";');
fprintf(fileID,'%s\n','    object      porosityProperties;');
fprintf(fileID,'%s\n','}');
fprintf(fileID,'\n');
fprintf(fileID,'%s\n','// *************************DEB POROSITY PROPERTIES***************************** //');
fprintf(fileID,'\n');

for i = 1:nGrain
  if (Grain(i).type ~= 4)
      porositystr = sprintf('slice%dZ%d_porosity%d',slice_id,xlev,i);
      fprintf(fileID,'%s \n',porositystr);
      fprintf(fileID,'%c\n','{');
    
      fprintf(fileID,'%s %s\n','    type','             DarcyForchheimer;');
      fprintf(fileID,'\n');
    
      fprintf(fileID,'%s %s %s%c\n','    cellZone','        ',Grain(i).NAME,';');
      fprintf(fileID,'\n');
      if(K == 1)
        fprintf(fileID,'%s %c%s%s %s%s %s%s%s \n','    d','(', Grain(i).K1,'e12', Grain(i).K2,'e12', Grain(i).K3,'e12',');'); %K1
      end
      if(K == 2)
        fprintf(fileID,'%s %c%s%s %s%s %s%s%s \n','    d','(', Grain(i).K2,'e12', Grain(i).K1,'e12', Grain(i).K3,'e12',');'); %K2
      end
      if(K == 3)
        fprintf(fileID,'%s %c%s%s %s%s %s%s%s \n','    d','(', Grain(i).K3,'e12', Grain(i).K3,'e12', Grain(i).K3,'e12',');'); %K3
      end
      fprintf(fileID,'%s %c%0.2f %0.2f %0.2f%s \n','    f','(',0,0,0,');');
      
      fprintf(fileID,'\n');
      fprintf(fileID,'%s\n','    coordinateSystem');
      fprintf(fileID,'%s\n','    {');
      fprintf(fileID,'%s %s\n','      type','        cartesian;');
      fprintf(fileID,'%s %s%d %d %d%s\n','      origin','      (',0,0,0,');');
      fprintf(fileID,'%s\n','      rotation');
      fprintf(fileID,'%s\n','      {');
      fprintf(fileID,'%s %s\n','        type','    axes;');
      if(K == 1)
        fprintf(fileID,'%s %s%d %d %d%s\n','        e1','       (',1,0,0,');');  %K2
        fprintf(fileID,'%s %s%d %d %d%s\n','        e2','       (',0,0,1,');');
      end
      if(K == 2)
        fprintf(fileID,'%s %s%d %d %d%s\n','        e1','       (',0,1,0,');');  %K1
        fprintf(fileID,'%s %s%d %d %d%s\n','        e2','       (',0,0,1,');');
      end
      if(K == 3)
        fprintf(fileID,'%s %s%d %d %d%s\n','        e1','       (',0,0,1,');');  %K2
        fprintf(fileID,'%s %s%d %d %d%s\n','        e2','       (',0,1,0,');');
      end
    
      fprintf(fileID,'%s\n','      }');
      fprintf(fileID,'%s\n','    }');
      fprintf(fileID,'\n');
      fprintf(fileID,'%s %s%c\n','    porosity  ',Grain(i).phi,';');
      fprintf(fileID,'%c\n','}');
      fprintf(fileID,'%c\n','');
  end
end

fprintf(fileID,'%c\n','');
fprintf(fileID,'%s\n','// ******************************************** //');
fclose(fileID);
fprintf("I have completed writing prosity file for K = %d\n", K);
end

