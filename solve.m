function F = solve(T_ins, dc, amb)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% F = [dc.get_q_cond_tot(T_ins) - dc.get_q_cond_conv(T_ins, amb) - dc.get_q_cond_rad(T_ins, amb);
%         dc.get_q_dr_1() + dc.get_q_ref(amb) + (dc.get_q_cond_tot(T_ins) + dc.get_q_conv_tot(amb) + dc.get_q_rad_emit(amb)) - dc.get_q_in(amb)];
F = [dc.get_q_cond_tot(T_ins) - dc.get_q_cond_conv(T_ins, amb) - dc.get_q_cond_rad(T_ins, amb)];
end

