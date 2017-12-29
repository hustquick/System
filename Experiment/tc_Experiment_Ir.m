%% Calculation for trough collector
clear;

% Experimental data
DNI = [353	408	464	476	497	508	553	610	637	652];
T_amb = 273.15 + [4.6	4.8	5.0	5.2	5.2	5.4	5.4	5.6	5.6	5.7];
v_wind = [0.5   0.4	0.4	0.3	0.3	0.3	0.3	0.3	0.3	0.4];
%T_o_measured_ = [570.1	602.3	624.5	630.7	671.3	705.3	716.8	...
 %   723.1	731.6	739.7];

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
    tc(k).st_i.T.v = 433.2;   % Design parameter
    tc(k).st_i.p.v = 4e5;
    tc(k).st_i.q_m.v = 0.2;
    
    tc(k).calculate_T_o();
    T_o(k) = tc(k).st_o.T.v; 
    Q_use(k) = tc(k).q_use;
    eta(k) = tc(k).eta;
    
    %%  Measured values
    [Cp(k), a, b] = Cp_oil((tc(k).st_i.T.v + T_o(k))/2);
    
    c(k) = - 1/2 * a * tc(k).st_i.T.v^2 - b * tc(k).st_i.T.v - ...
        Q_use(k) ./ tc(k).st_i.q_m.v;
    T_o_m(k) = (-b + (b^2-2*a*c(k))^0.5) ./ a;
    T_o_measured(k) = round((T_o_m(k) + 0.1 - rand() * 0.2) .* 10) ./ 10;
    
    Q_use_measured(k) = 1 / 2 * a * (T_o_measured(k)^2 - ...
        tc(k).st_i.T.v^2) * tc(k).st_i.q_m.v + b * (...
        T_o_measured(k) - tc(k).st_i.T.v) * tc(k).st_i.q_m.v;
    eta_measured(k) = Q_use_measured(k) / tc(k).amb.I_r / tc(k).A;
    %%  Calculated values
    T_abs(k) = (tc(k).st_i.T.v + T_o_measured(k))/2;
    U_abs(k) = 0.687257 + 0.001941 * (T_abs(k) - tc(k).amb.T.v) + ...
        0.000026 * (T_abs(k) - tc(k).amb.T.v)^2;
   
    eta_opt_0(k) = tc(k).rho .* tc(k).gamma .* tc(k).tau .* tc(k).alpha;
    q_bar(k) = tc(k).amb.I_r .* tc(k).w .* eta_opt_0(k) .* tc(k).K() ...
                .* tc(k).Fe ./ (pi * tc(k).d_o);
    large(k) = - U_abs(k) .* pi .* tc(k).d_o .* tc(k).A ./ (tc(k).w .* ...
        Cp(k) .* tc(k).st_i.q_m.v);
    T_o_calculated(k) = tc(k).amb.T.v + q_bar(k) ./ U_abs(k) + ...
        exp(large(k)) .* (tc(k).st_i.T.v - tc(k).amb.T.v - ...
        q_bar(k) ./ U_abs(k));
    Q_use_calculated(k) = 1 / 2 * a * (T_o_calculated(k)^2 - ...
        tc(k).st_i.T.v^2) * tc(k).st_i.q_m.v + b * (T_o_calculated(k) - ...
        tc(k).st_i.T.v) * tc(k).st_i.q_m.v;
    
    eta_calculated(k) = Q_use_calculated(k) / tc(k).amb.I_r / tc(k).A;
    
end

