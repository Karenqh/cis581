function newI = mirror_pad(I, mode, offset)
% Helper function for adding mirror_pad

% TODO: deal with even number of rows/cols
switch mode
    case 'Gx'
        left = fliplr( I(:, 1:offset) );
        right = fliplr( I(:, end-offset+1:end) );
        if offset == 1 % difference
            newI = [I, right];
        else
            
            newI = [left, I, right];
        end

    case 'Gy'
        top = flipud( I(1:offset, :) );
        bottom = flipud( I(end-offset+1:end, :) );
        if offset == 1
            newI = [I; bottom];
        else
            newI = [top; I; bottom];
        end

    case 'Gxy'
        left = fliplr( I(:, 1:offset) );
        right = fliplr( I(:, end-offset+1:end) );
        top = flipud( I(1:offset, :) );
        bottom = flipud( I(end-offset+1:end, :) );

        left_upper = rot90(I(1:offset, 1:offset),2);
        right_upper = rot90(I(1:offset, end-offset+1:end),2);
        left_bottom = rot90(I(end-offset+1:end, 1:offset),2);
        right_bottom = rot90(I(end-offset+1:end, end-offset+1:end),2);
        
        if offset ~= 1
            newI = [left, I, right];
            newI = [left_upper top right_upper; newI; ...
                left_bottom bottom right_bottom];
        else
            newI = [I, right];
            newI = [newI;bottom right_bottom];
        end

end
end