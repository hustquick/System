clear;
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 1;
st1.T.v = 1073.15;
st1.p.v = 5e5;

sea = SEC(3,'Series');
sea.st1_i = st1;
sea.calculate;