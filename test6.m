%% Calculation for dish collector
clear;
num = 7;
result = zeros(1, num);
result2 = zeros(1, num);
for k = 1 : num
    dc(k) = DishCollector;

    dc(k).amb.I_r = 200 + (k - 1) * 50;
    %dc.A = 19.79;
    dc(k).st_i.fluid = char(Const.Fluid(1));
    dc(k).st_i.T.v = convtemp(150, 'C', 'K');   % Design parameter
    dc(k).st_i.p.v = 4e5;
    dc(k).st_i.q_m.v = 0.07;
    
    dc(k).get_T_o();
    result(k) = dc(k).st_o.T.v -273.15;
    result2(k) = dc(k).q_use;
    effi(k) = dc(k).eta;
    I_r(k) = dc(k).amb.I_r;
end