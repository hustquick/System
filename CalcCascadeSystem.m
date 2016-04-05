function F = CalcCascadeSystem(x, cs)
%CalcCascadeSystem Use expressions to calculation parameters of cascade
%system

cs.st2(1).q_m.v = x(1);
cs.st2(2).q_m.v = x(2);
F = [cs.ge.P ./ cs.ge.eta - cs.tb.P;
    cs.da.q_m.v - cs.st2(7).q_m.v];

end

