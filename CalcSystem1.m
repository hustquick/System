function F = CalcSystem1(x, cs)
%CalcSystem Use expressions to calculate some parameters of the system
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways
%     x = zeros(sea.n1,2);
cs.tb.st_i.q_m.v = x(cs.sea.n1 + 1, 1);
cs.tb.work(cs.ge);
cs.cd.work();
cs.pu1.p = cs.da.p;
cs.pu1.work();

cp_1 = cs.sea.st1_i.cp;
cp_2 = cs.sea.st2_i.cp;
cs.sea.se(1).st1_i = cs.sea.st1_i_r;
cs.sea.se(1).st1_i.flowTo(cs.sea.se(1).st1_o);
cs.sea.se(1).st1_o.p = cs.sea.se(1).st1_i.p;
cs.sea.se(1).cp_1 = cp_1;

if (strcmp(cs.sea.order, 'Same'))
    %%%%% Same order %%%%%
    cs.sea.se(1).st2_i = cs.sea.st2_i_r;
    cs.sea.se(1).st2_i.flowTo(cs.sea.se(1).st2_o);
    cs.sea.se(1).st2_o.p = cs.sea.se(1).st2_i.p;
    cs.sea.se(1).cp_2 = cp_2;
    for i = 2 : cs.sea.n1
        cs.sea.se(i).cp_1 = cp_1;
        cs.sea.se(i).cp_2 = cp_2;
        cs.sea.se(i).st1_i = cs.sea.se(i-1).st1_o;
        cs.sea.se(i).st2_i = cs.sea.se(i-1).st2_o;
        cs.sea.se(i).st1_i.flowTo(cs.sea.se(i).st1_o);
        cs.sea.se(i).st1_o.p = cs.sea.se(i).st1_i.p;
        cs.sea.se(i).st2_i.flowTo(cs.sea.se(i).st2_o);
        cs.sea.se(i).st2_o.p = cs.sea.se(i).st2_i.p;
    end
elseif (strcmp(cs.sea.order,'Reverse'))
    %%%%% Inverse order %%%%%
    cs.sea.se(1).cp_2 = cp_2;
    for i = 2 : cs.sea.n1
        cs.sea.se(i).cp_1 = cp_1;
        cs.sea.se(i).cp_2 = cp_2;
    end
    cs.sea.se(cs.sea.n1).st2_i = cs.sea.st2_i_r;
    cs.sea.se(cs.sea.n1).st2_i.flowTo(cs.sea.se(cs.sea.n1).st2_o);
    cs.sea.se(cs.sea.n1).st2_o.p = cs.sea.se(cs.sea.n1).st2_i.p;
    
    for i = 1 : cs.sea.n1-1
        cs.sea.se(i+1).st1_i = cs.sea.se(i).st1_o;
        cs.sea.se(cs.sea.n1-i).st2_i = cs.sea.se(cs.sea.n1+1-i).st2_o;
        
        cs.sea.se(i+1).st1_i.flowTo(cs.sea.se(i+1).st1_o);
        cs.sea.se(i+1).st1_o.p = cs.sea.se(i+1).st1_i.p;
        cs.sea.se(cs.sea.n1-i).st2_i.flowTo(cs.sea.se(cs.sea.n1-i).st2_o);
        cs.sea.se(cs.sea.n1-i).st2_o.p = cs.sea.se(cs.sea.n1-i).st2_i.p;
    end
else
    error('Uncomplished work.');
end

for i = 1 : cs.sea.n1
    cs.sea.se(i).st1_o.T.v = x(i, 1);
    cs.sea.se(i).st2_o.T.v = x(i, 2);
end

F = zeros(cs.sea.n1,2);
for j = 1 : cs.sea.n1
    F(j,1) = 1 - cs.sea.se(j).eta1() ./ cs.sea.se(j).eta2();
    F(j,2) = 1 - cs.sea.se(j).P1() ./ cs.sea.se(j).P2();
end

if (strcmp(cs.sea.order, 'Same'))
    cs.sea.se(cs.sea.n1).st2_o.convergeTo(cs.sea.st2_o, cs.sea.n2);
elseif (strcmp(cs.sea.order,'Reverse'))
    cs.sea.se(1).st2_o.convergeTo(cs.sea.st2_o, cs.sea.n2);
else
    error('Uncomplished work.');
end

T1 = cs.sea.st2_o.T.v;
cs.da.work(cs.tb);
F(cs.sea.n1+1, 1) = T1 - cs.da.st_i_2.T.v;

end