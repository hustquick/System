clear
clc
se = StirlingEngine;
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.T.v = 1073.15;
st1.p.v = 5e5;
st1.q_m.v = 3;

st2 = Stream;
st2.fluid = char(Const.Fluid(2));
st2.T.v = 293.15;
st2.p.v = 1.01325e5;
st2.q_m.v = 6.7;

se.st1_i = st1;
se.st2_o = st2;

se.get_i;