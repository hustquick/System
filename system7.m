clear;
% Different kinds of connection form of Stirling engines
number = 10;
eta1 = zeros(1, number);
eta2 = zeros(1, number);
eta3 = zeros(1, number);
eta4 = zeros(1, number);
eta5 = zeros(1, number);
P1 = zeros(1, number);
P2 = zeros(1, number);
P3 = zeros(1, number);
P4 = zeros(1, number);
P5 = zeros(1, number);
for k = 1 : number
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 0.3 * k;
st1.T.v = 1073.15;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(1));
st2.q_m.v = 0.3 * k;
st2.T.v = 303.15;
st2.p.v = 5e5;

sea1 = SEA;
sea1.n1 = 1;
sea1.n2 = 5;
sea1.order = 'Same';
sea1.st1_i = st1;
sea1.st2_i = st2;

sea2 = SEA;
sea2.n1 = 1;
sea2.n2 = 5;
sea2.order = 'Reverse';
sea2.st1_i = st1;
sea2.st2_i = st2;

sea3 = SEC(5,'Parallel');
sea3.st1_i = st1;
sea3.st2_i = st2;

sea4 = SEC(5,'Serial1');
sea4.st1_i = st1;
sea4.st2_i = st2;

sea5 = SEC(5,'Serial2');
sea5.st1_i = st1;
sea5.st2_i = st2;

sea1.calculate;
sea2.calculate;
sea3.calculate;
sea4.calculate;
sea5.calculate;

eta1(k) = sea1.eta;
eta2(k) = sea2.eta;
eta3(k) = sea3.eta;
eta4(k) = sea4.eta;
eta5(k) = sea5.eta;
P1(k) = sea1.P;
P2(k) = sea2.P;
P3(k) = sea3.P;
P4(k) = sea4.P;
P5(k) = sea5.P;
end