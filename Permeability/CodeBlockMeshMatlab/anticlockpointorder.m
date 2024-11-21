%% Anti-clockwise ordering of nodes in every element according to OpenFOAM
function [B] = anticlockpointorder(A, x, y, n1, n2, n3, n4)
    
    X = [A(n1,x) A(n2,x), A(n3,x), A(n4,x)];
    Y = [A(n1,y) A(n2,y), A(n3,y), A(n4,y)];
    
        for i = 1:4
            if((min(X) == X(i)) && (min(Y) == Y(i)))
                elmx1 = i;     
                if(i == 1)
                    x1 = n1;
                elseif (i ==2)
                    x1 = n2;
                elseif (i == 3)
                    x1 = n3;
                else
                    x1 = n4;
            end
        end
    end
       
    for i = 1:4
        if((X(i) > (X(elmx1))) && (Y(i) == Y(elmx1)))
            elmx2 = i;
    
            if(i == 1)
                x2 = n1;
            elseif (i ==2)
                x2 = n2;
            elseif (i == 3)
                x2 = n3;
            else
                x2 = n4;
            end
        end
    end
       
    for i = 1:4
        if((X(i) == (X(elmx2))) && (Y(i) > Y(elmx2)))
            elmx3 = i;
            
            if(i == 1)
                x3 = n1;
            elseif (i ==2)
                x3 = n2;
            elseif (i == 3)
                x3 = n3;
            else
                x3 = n4;
            end
        end
    end
       
    for i = 1:4
        if((X(i) < (X(elmx3))) && (Y(i) == Y(elmx3)))
          
            if(i == 1)
                x4 = n1;
            elseif (i ==2)
                x4 = n2;
            elseif (i == 3)
                x4 = n3;
            else
                x4 = n4;
            end
        end
    end
    
    B = [x1 x2 x3 x4];  % anit clockwise odreding of co-ordinate points

end