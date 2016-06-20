st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 1;
st1.T.v = 1073.15;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(2));
st2.q_m.v = 1;
st2.T.v = 303.15;
st2.p.v = 1e5;

sea = SEA(2,3,'Same');
sea.st1_i = st1;
sea.st2_i = st2;
sea.calculate;