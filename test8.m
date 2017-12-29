%% Calculation for trough collector
clear;

% Experimental data
DNI = [303	358	414	426	512	596	620	641	658	683];
T_amb = 273.15 + [8.9    9.3	10.0	10.2	11.8	14.2	16.0	...
    16.3	16.2	16.3];
v_wind = [0.8	0.8	0.7	0.7	0.5	0.4	0.4	0.4	0.4	0.4];
T_o_measured = [570.1	602.3	624.5	630.7	671.3	705.3	716.8	...
    723.1	731.6	739.7];

num = length(DNI);

tc = TroughCollector.empty;
eta = zeros(1,num);
T_o = zeros(1, num);
Q_use = zeros(1, num);
h_o_measured = zeros(1,num);
h_i = zeros(1,num);
Q_use_measured = zeros(1,num);
eta_measured = zeros(1,num);
for k = 1 : num
    tc(k) = TroughCollector;

    tc(k).amb.I_r = DNI(k);
    tc(k).amb.T.v = T_amb(k);
    tc(k).amb.w = v_wind(k);
    tc(k).st_i.fluid = char(Const.Fluid(3));
    tc(k).st_i.T.v = convtemp(160, 'C', 'K');   % Design parameter
    tc(k).st_i.p.v = 4e5;
    tc(k).st_i.q_m.v = 0.4;
    
    tc(k).calculate_T_o();
    T_o(k) = tc(k).st_o.T.v; %-273.15;
    Q_use(k) = tc(k).q_use;
    eta(k) = tc(k).eta;
    
    h_o_measured(k) = CoolProp.PropsSI('H', 'T', T_o_measured(k), ...
        'P', 4e5, char(Const.Fluid(1)));
    h_i(k) = CoolProp.PropsSI('H', 'T', tc(k).st_i.T.v, ...
        'P', 4e5, char(Const.Fluid(1)));
    Q_use_measured(k) = tc(k).st_i.q_m.v .* (h_o_measured(k) - h_i(k));
    eta_measured(k) = eta(k) .* Q_use_measured(k) ./ Q_use(k);
end

