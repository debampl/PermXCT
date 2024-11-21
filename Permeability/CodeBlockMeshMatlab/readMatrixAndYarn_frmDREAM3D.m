function [NODE, ELM, Grain, nGrain] = readMatrixAndYarn_frmDREAM3D(DIR, slice_id, xlev)
    % clear all;
    % clc
    %%%%%%%%%%%%%%%% 
    % DIR = 'C:\Users\debaa\Documents\TURBO_FoamSimulation\XCT_NCF_Permeability\ABAQUS_INP_MESH\';


%% READ Entire Node Set
    nodeFile = sprintf('slice_%dZ%d_nodes.inp',slice_id,xlev);

    DIR_NODE = fullfile(DIR, nodeFile);
    
    fid_nodeStr = textread(DIR_NODE,'%s','delimiter','\n');
    fid_nodeDataRead = fopen(DIR_NODE, 'rt');
    
    strNode = find(~cellfun(@isempty,strfind(fid_nodeStr,'*Node')));
    totalNodeLine = size(fid_nodeStr(:,1));
    endNodeLine = totalNodeLine(1) - strNode - 4;  % No need to scan last 4 lines 
    node_scan = textscan(fid_nodeDataRead,'%s',1,'delimiter','\n', 'headerlines',strNode-1);
    NODE = textscan(fid_nodeDataRead, '%d%c %f%c %f%c %f%c', endNodeLine);
    fclose(fid_nodeDataRead);
    fprintf("I am finished reading inp files of nodes\n");
%% READ Entire Element Set
    elmFile = sprintf('slice_%dZ%d_elems.inp',slice_id,xlev);
    DIR_ELEM = fullfile(DIR, elmFile);
    
    fid_elemStr = textread(DIR_ELEM,'%s','delimiter','\n');
    fid_elemDataRead = fopen(DIR_ELEM, 'rt');
    
    ElemsetYarnIndex = find(~cellfun(@isempty,strfind(fid_elemStr,'*Elset, elset=Grain')));
    
    strElem = find(~cellfun(@isempty,strfind(fid_elemStr,'*Element, type=C3D8')));
    totalElemLine = size(fid_elemStr(:,1));
    endElemLine = totalElemLine(1) - strElem - 3;  % No need to scan last 3 lines 
    elem_scan = textscan(fid_elemDataRead,'%s',1,'delimiter','\n', 'headerlines',strElem-1);
    ELM = textscan(fid_elemDataRead, '%d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d', endElemLine);
    fclose(fid_elemDataRead);
    fprintf("I am finished reading inp files of total element\n");

%% READ Grain Element Set
    elsetFile = sprintf('slice_%dZ%d_elset.inp',slice_id,xlev);
    Grain_ELEM = fullfile(DIR,elsetFile);
    
    fid_grainStr = textread(Grain_ELEM,'%s','delimiter','\n');
    fid_grainDataRead = fopen(Grain_ELEM, 'rt');
    
    ElemsetGrainIndex = find(~cellfun(@isempty,strfind(fid_grainStr,'*Elset, elset=Grain')));
    
    grainSetTotalLine = size(fid_grainStr(:,1));
    grainSetEndLine = grainSetTotalLine(1) - 3;  % No need to scan last 3 lines 

%% Type the identification string for Yarn
    for i = 1:numel(ElemsetGrainIndex)
        Grain(i).Index = ElemsetGrainIndex(i);
    end

%% READ Yarn Element Set
    for i = 1:numel(ElemsetGrainIndex)
        
    %   i = 29969;
        frewind(fid_grainDataRead);  % Used to reset the file pointer to the start of the file
        grainElmSet = textscan(fid_grainDataRead,'%s',1,'delimiter','\n', 'headerlines',Grain(i).Index-1);
    
        if(i == numel(ElemsetGrainIndex))
            totalGrainElmNum = grainSetEndLine- Grain(i).Index;
        else
            totalGrainElmNum = Grain(i+1).Index - Grain(i).Index;
        end
        
        grainElm = textscan(fid_grainDataRead, '%d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c %d%c',totalGrainElmNum);
    
        Y1 = grainElm{1,1};
        Y2 = grainElm{1,3};
        Y3 = grainElm{1,5};
        Y4 = grainElm{1,7};
        Y5 = grainElm{1,9};
        Y6 = grainElm{1,11};
        Y7 = grainElm{1,13};
        Y8 = grainElm{1,15};
        Y9 = grainElm{1,17};
        Y10 = grainElm{1,19};
        Y11 = grainElm{1,21};
        Y12 = grainElm{1,23};
        Y13 = grainElm{1,25};
        Y14 = grainElm{1,27};
        Y15 = grainElm{1,29};
        Y16 = grainElm{1,31};
    
        % GrainElm may contain Zero in the last entry for few cell
        % However there is no zero element in the element entry
        
        Grain(i).elm = [Y1; Y2; Y3; Y4; Y5; Y6; Y7; Y8; Y9; Y10; Y11; Y12; Y13; Y14; Y15; Y16];
        
        Grain(i).ELM = sort(Grain(i).elm); % ordering the element and search for zero element if there is any
    end
    fprintf("I am finished reading inp files of element sets for all the grains\n");

%% Define the grain type id from the separate ascii file
    matFiberInfoFile = sprintf('ascii_slice%dZ%d.txt',slice_id,xlev);
    DIR_MATFIBER_INFO = fullfile(DIR,matFiberInfoFile);
    
    [B] = matrixFiberInfo(DIR_MATFIBER_INFO);
    
    for i = 1:numel(ElemsetGrainIndex)
        Grain(i).type = B.fiber_class(i);
    end

    GrainSize = size(Grain);
    nGrain = GrainSize(2);
    fprintf("I am finished reading ASCII data file of grain type\n");
end
