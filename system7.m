clear;
% Different kinds of connection form of Stirling engines
number = 10;
eta1 = zeros(1, number);
eta2 = zeros(1, number);
eta3 = zeros(1, number);
eta4 = zeros(1, number);
for k = 1 : number
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 2;
st1.T.v = 1073.15;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(1));
st2.q_m.v = 2;
st2.T.v = 303.15;
st2.p.v = 1e5;

sea1 = SEA(1,k+2,'Same');
sea1.st1_i = st1;
sea1.st2_i = st2;

sea2 = SEA(1,k+2,'Reverse');
sea2.st1_i = st1;
sea2.st2_i = st2;

sea3 = SEC(k+2,'Parallel');
sea3.st1_i = st1;
sea3.st2_i = st2;

sea4 = SEC(k+2,'Series');
sea4.st1_i = st1;
sea4.st2_i = st2;

sea1.calculate;
sea2.calculate;
sea3.calculate;
sea4.calculate;

eta1(k) = sea1.eta;
eta2(k) = sea2.eta;
eta3(k) = sea3.eta;
eta4(k) = sea4.eta;
end