function  eta  = eta( T_H, T_L )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    e = 0.42;
    k = 1.4;
    gamma = 3.375;
        eta = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
        ./ (k -1) ./ (log(gamma)));
end

