function F = CalcDishCollector(x, dc, amb)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% F = [dc.q_cond_tot(T_ins) - dc.q_cond_conv(T_ins, amb) - dc.q_cond_rad(T_ins, amb);
%         dc.q_dr_1() + dc.q_ref(amb) + (dc.q_cond_tot(T_ins) + dc.q_conv_tot(amb) + dc.q_rad_emit(amb)) - dc.q_in(amb)];
F = [dc.q_dr_1_h(x(3)) - dc.q_dr_1(x(1), x(3));
    dc.q_cond_tot(x(1), x(2)) - dc.q_cond_conv(x(2), amb) - ...
    dc.q_cond_rad(x(2), amb);
    dc.q_dr_1(x(1), x(3)) + dc.q_ref(amb) + (dc.q_cond_tot(x(1), x(2)) ...
    + dc.q_conv_tot(x(1), amb) + dc.q_rad_emit(x(1), amb)) - dc.q_in(amb)];
end

