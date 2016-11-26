function F = Calc_sea_reverse(x, sea, T0)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    sea(1,1).st2_o.T.v = x;
    sea(1,1).get_i;
    
    % Calculate each engine in first row
    for i = 1 : numel(sea(1,:)) - 1
        sea(1, i+1).st1_i = sea(1,i).st1_o;
        sea(1, i+1).st2_o = sea(1,i).st2_i;
        sea(1, i+1).get_i;
    end
    
    F = sea(1, numel(sea(1,:))).st2_i.T.v - T0;
end

