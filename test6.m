%% Calculation for dish collector
clear;
num = 1;
result = zeros(1, num);
result2 = zeros(1, num);
for k = 1 : num
    dc = DishCollector;

    dc.amb.I_r = 400;
    %dc.A = 19.79;
    dc.st_i.fluid = char(Const.Fluid(1));
    dc.st_i.T.v = convtemp(150, 'C', 'K');   % Design parameter
    dc.st_i.p.v = 4e5;
    dc.st_i.q_m.v = 0.07;
    
    dc.get_T_o();
    result(k) = dc.st_o.T.v -273.15;
    result2(k) = dc.q_use;
end