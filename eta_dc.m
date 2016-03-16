function eta_dc = eta_dc(T_dr_i, T_dr_o )
%This function is used to calculate the efficiency of dish receiver
%   This calculation is under given parameters of the dish collector
%   The effciency is irrelavent with air flow rate
    global I_r T_amb p_amb v_wind F1 p_dr
    A_dc = 87.7; % Aperture area of dish collector, m^2
    gamma_dc = 0.97; % Intercept factor of dish receiver
    eta_shading_dc = 0.95;   % Shading factor of dish receiver
    rho_dc = 0.91;   % Reflectivity of dish collector
    
    q_in = I_r * A_dc * gamma_dc * eta_shading_dc * rho_dc
    
    % Parameters of receiver
    d_cav = 0.46    % Diameter of the cavity of dish receiver, m
    d_ap = 0.184    % Aperture diameter of dish receiver, m
    dep_cav = 0.184 % Depth of the cavity of dish receiver, m
    delta_ins = 0.075   % Thickness of dish receiver insulating layer
    
    eta_dc = CoolProp.PropsSI('H', 'T', T_dr_o, 'P', p_dr, F1)
end

