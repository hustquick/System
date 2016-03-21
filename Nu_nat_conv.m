function Nu = Nu_nat_conv(Gr, T_cav, T_amb, theta, d_ap, d_bar_cav)
%Nu_nat_cav This function discribes the corrilation of Nusselt number of the cavity
S = - 0.982 * (d_ap / d_bar_cav) + 1.12;
Nu = 0.088 * Gr .^ (1/3) .* (T_cav ./ T_amb) .^ 0.18 ...
    .* (cos(theta))^2.47 .* (d_ap / d_bar_cav) .^ S;
end