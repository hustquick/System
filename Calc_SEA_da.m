function F = Calc_SEA_da(x, cs)
    cs.tb.st_i.q_m.v = x;
    cs.tb.work(cs.ge);
    cs.cd.work();
    cs.pu1.p = cs.da.p;
    cs.pu1.work();
    cs.sea.calculate();
    T0 = cs.sea.st2_o.T.v;
    cs.da.work(cs.tb);
    F = cs.sea.st2_o.T.v - T0;
end