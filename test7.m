%% Calculation for trough collector
clear;
num = 1;
result = zeros(1, num);
result2 = zeros(1, num);
L = 20;
for k = 1 : 1
    tc(k) = TroughCollector;

    tc(k).amb.I_r = 500;
    %dc.A = 19.79;
    tc(k).st_i.fluid = char(Const.Fluid(3));
    tc(k).st_i.T.v = convtemp(160, 'C', 'K');   % Design parameter
    tc(k).st_i.p.v = 5e5;
% 	tc(k).st_i.q_m.v = 0.37;
    
    tc(k).st_o.fluid = tc(k).st_i.fluid;
    tc(k).st_o.T.v = tc(k).st_i.T.v + 20;
    tc(k).st_o.p.v = tc(k).st_i.p.v;
    tc(k).st_o.q_m.v = tc(k).st_i.q_m.v;
    
    tc(k).st_i.q_m.v = L / tc(k).L_per_q_m;
 
    q_m(k) = tc(k).st_i.q_m.v;
    eta(k) = tc(k).eta;
    T2(k) = tc(k).st_o.T.v - 273.15;
   %  tc.get_T_o();
%     result(k) = tc.st_o.T.v -273.15;
%     result2(k) = tc.q_use;
end