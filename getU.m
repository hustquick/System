function U = getU(T)
%This function is used to calculate the overall heat transfer
%coefficient of trough receiver with the fluid temperature of T.
%   U   overall heat transfer coefficient of trough recevier
%   T   temperature of fluid
global T_amb 
if (T < C2K(200))
    U = 0.687257 + 0.001941 * (T - T_amb) + 0.000026 * (T - T_amb).^2
elseif (T > C2K(300))
    U = 1.433242 - 0.00566 * (T - T_amb) + 0.000046 * (T - T_amb).^2
else
    U = 2.895474 - 0.0164 * (T - T_amb) + 0.000065 * (T - T_amb).^2
end
end

