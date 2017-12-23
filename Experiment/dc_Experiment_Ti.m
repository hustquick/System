%% Calculation for dish collector
clear;
num = 5;
dc = DishCollector.empty;
eta = zeros(1,num);
T_o = zeros(1, num);
Q_use = zeros(1, num);
I_r = zeros(1,num);
h_o_measured = zeros(1,num);
h_i = zeros(1,num);
Q_use_measured = zeros(1,num);
eta_measured = zeros(1,num);

% Experimental data
DNI = [616	614	610	618	615];
T_amb = 273.15 + [16.3	15.1	15.5	15.7	15.7];
v_wind = [0.4	0.4	0.4	0.4	0.4];
T_i = [383.15	403.15	423.15	443.15	463.15];
T_o_measured = [660.6	674.0	685.3	702.8	714.8];
for k = 1 : num
    dc(k) = DishCollector;

    dc(k).amb.I_r = DNI(k);
    dc(k).amb.T.v = T_amb(k);
    dc(k).amb.w = v_wind(k);
    dc(k).st_i.fluid = char(Const.Fluid(1));
    dc(k).st_i.T.v = T_i(k);   % Design parameter
    dc(k).st_i.p.v = 4e5;
    dc(k).st_i.q_m.v = 0.03;
    
    dc(k).get_T_o();
    T_o(k) = dc(k).st_o.T.v; %-273.15;
    Q_use(k) = dc(k).q_use;
    eta(k) = dc(k).eta;
    I_r(k) = dc(k).amb.I_r;
    
    h_o_measured(k) = CoolProp.PropsSI('H', 'T', T_o_measured(k), ...
        'P', 4e5, char(Const.Fluid(1)));
    h_i(k) = CoolProp.PropsSI('H', 'T', dc(k).st_i.T.v, ...
        'P', 4e5, char(Const.Fluid(1)));
    Q_use_measured(k) = dc(k).st_i.q_m.v .* (h_o_measured(k) - h_i(k));
    eta_measured(k) = eta(k) .* Q_use_measured(k) ./ Q_use(k);
end