clear;
amb = Ambient;
tc = TroughCollector;
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.T = Temperature(convtemp(120, 'C', 'K'));
st1.p.v = 5e5;
st1.q_m.v = 0.06;

st2 = Stream;
st1.flowTo(st2);
st2.p = st1.p;
st2.T = Temperature(convtemp(300, 'C', 'K'));

amb.I_r = 700;
tc.st_i = st1;
tc.st_o = st2;
tc.amb = amb;
tc.L_per_q_m;