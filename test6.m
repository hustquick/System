clear;
num = 6;
result = zeros(1, num);
for k = 1 : num
    dc = DishCollector;

    dc.amb.I_r = 600;
%     dc.A = 19.79;
    dc.st_i.fluid = char(Const.Fluid(1));
    dc.st_i.T.v = convtemp(400, 'C', 'K');   % Design parameter
    dc.st_i.p.v = 5e5;
    dc.st_i.q_m.v = 0.01;
    dc.st_o.T.v = convtemp(800, 'C', 'K');
    dc.get_A();
    result(k) = dc.A;
end