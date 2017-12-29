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
DNI = [613	615	616	614	613];
T_amb = 273.15 + [13.1	13.2	13.4	13.5	13.5];
v_wind = [0.4	0.4	0.4	0.4	0.4];
T_i = [423.15	423.15	423.15	423.15	423.15];
q_m = [0.01	0.02	0.03	0.04	0.05];
for k = 1 : num
    dc(k) = DishCollector;

    dc(k).amb.I_r = DNI(k);
    dc(k).amb.T.v = T_amb(k);
    dc(k).amb.w = v_wind(k);
    dc(k).st_i.fluid = char(Const.Fluid(1));
    dc(k).st_i.T.v = T_i(k);   % Design parameter
    dc(k).st_i.p.v = 4e5;
    dc(k).st_i.q_m.v = q_m(k);
    
    dc(k).insLayer.epsilon = 0.2;
    dc(k).insLayer.lambda = 0.6;
    dc(k).rho = 0.74;
    
    dc(k).get_T_o();
    T_o(k) = dc(k).st_o.T.v; %-273.15;
    Q_use(k) = dc(k).q_use;
    eta(k) = dc(k).eta;
    
    T_o_measured(k) = round((T_o(k) + 4 * (0.1 - rand() * 0.2)) .* 10) ./ 10;
    h_o_measured(k) = CoolProp.PropsSI('H', 'T', T_o_measured(k), ...
        'P', 4e5, char(Const.Fluid(1)));
    h_i(k) = CoolProp.PropsSI('H', 'T', dc(k).st_i.T.v, ...
        'P', 4e5, char(Const.Fluid(1)));
    Q_use_measured(k) = dc(k).st_i.q_m.v .* (h_o_measured(k) - h_i(k));
    eta_measured(k) = eta(k) .* Q_use_measured(k) ./ Q_use(k);
    
    dc(k).insLayer.epsilon = 0.1;
    dc(k).insLayer.lambda = 0.26;
    dc(k).rho = 0.71;
    
    dc(k).get_T_o();
    T_o(k) = dc(k).st_o.T.v;
    Q_use(k) = dc(k).q_use;
    eta(k) = dc(k).eta;
end