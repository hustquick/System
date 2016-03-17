function F = CalcDishCollector(x, dc, amb)
%CalcDishCollector Use expressions to calculation parameters of dish
%collector
%   First expression expresses q_dr_1 in two different forms
%   Second expression expresses q_cond_tot = q_cond_conv + q_cond_rad
%   Third expression expresses q_in = q_ref + q_dr_1 + q_cond_tot +
%   q_conv_tot + q_rad_emit
F = [dc.q_dr_1_h(x(3)) - dc.q_dr_1(x(1), x(3));
    dc.q_cond_tot(x(1), x(2)) - dc.q_cond_conv(x(2), amb) - ...
    dc.q_cond_rad(x(2), amb);
    dc.q_dr_1(x(1), x(3)) + dc.q_ref(amb) + (dc.q_cond_tot(x(1), x(2)) ...
    + dc.q_conv_tot(x(1), amb) + dc.q_rad_emit(x(1), amb)) - dc.q_in(amb)];
end

