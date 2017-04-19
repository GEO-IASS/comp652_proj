function dirmov = movementdirection(up,right)
        dirmov = NaN;
            if up == -1 && right == -1 %case '-1  -1'
                dirmov = 1;
            elseif up == -1 && right == 0 %case '-1  0'
                dirmov = 2;
            elseif up == -1 && right == 1 %case '-1  1'
                dirmov = 3;
            elseif up == 0 && right == -1 %case '0  -1'
                dirmov = 4;
            elseif up == 0 && right == 0 %case '0  0'
                dirmov = 5;
            elseif up == 0 && right == 1 %case '0  1'
                dirmov = 6;
            elseif up == 1 && right == -1 %case '1  -1'
                dirmov = 7;
            elseif up == 1 && right == 0 %case '1  0'
                dirmov = 8;
            elseif up == 1 && right == 1 %case '1  1'
                dirmov = 9;
            end
end

