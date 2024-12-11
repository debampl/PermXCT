function [B] = matrixFiberInfo(data_info)

    M = dlmread(data_info,',',1,0);

    Name = {'fiber_class';'grain_id'};
    A = table(M(:,1),M(:,2),'VariableNames',Name);

    [C,ia] = unique(A.grain_id);

    B = A(ia,:);
end
