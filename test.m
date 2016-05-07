clear;
sec = SEC(3, 'Series');
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.T.v = 1073.15;
st1.p = 5e5;
st1.q_m.v = 0.67;

st2 = Stream;
st2.fluid = char(Const.Fluid(2));
st2.T.v = 293.15;
st2.p = 1.01325e5;
st2.q_m.v = 0.9;

sec.st1_i = st1;
sec.st2_i = st2;
sec.calculate;