clear all;
% Different kinds of connection form of Stirling engines
number = 15;
n_se = 6;
sea1 = SEC.empty;
sea2 = SEA.empty;
sea3 = SEA.empty;
sea4 = SEC.empty;
sea5 = SEC.empty;

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
T1 = zeros(1, number);

for k = 1 : number
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.q_m.v = 0.4;        % Change this value
st1.T.v = 670 + 30 * k;
st1.p.v = 5e5;

st2 = Stream;
st2.fluid = char(Const.Fluid(1));
st2.q_m.v = 0.4;
st2.T.v = 300;
st2.p.v = 5e5;

sea1(k) = SEC(n_se,'Parallel');
sea1(k).st1_i = st1;
sea1(k).st2_i = st2;

sea2(k) = SEA;
sea2(k).n1 = 1;
sea2(k).n2 = n_se;
sea2(k).order = 'Same';
sea2(k).st1_i = st1;
sea2(k).st2_i = st2;

sea3(k) = SEA;
sea3(k).n1 = 1;
sea3(k).n2 = n_se;
sea3(k).order = 'Reverse';
sea3(k).st1_i = st1;
sea3(k).st2_i = st2;

sea4(k) = SEC(n_se,'Serial1');
sea4(k).st1_i = st1;
sea4(k).st2_i = st2;

sea5(k) = SEC(n_se,'Serial2');
sea5(k).st1_i = st1;
sea5(k).st2_i = st2;

sea1(k).calculate;
sea2(k).calculate;
sea3(k).calculate;
sea4(k).calculate;
sea5(k).calculate;

eta1(k) = sea1(k).eta;
eta2(k) = sea2(k).eta;
eta3(k) = sea3(k).eta;
eta4(k) = sea4(k).eta;
eta5(k) = sea5(k).eta;
P1(k) = sea1(k).P;
P2(k) = sea2(k).P;
P3(k) = sea3(k).P;
P4(k) = sea4(k).P;
P5(k) = sea5(k).P;
T1(k) = st1.T.v;
end

subplot(1,2,1);

plot(T1,eta1);
hold on
plot(T1,eta2);
plot(T1,eta3);
plot(T1,eta4);
plot(T1,eta5);
legend('1', '2', '3', '4', '5');

subplot(1,2,2);
plot(T1,P1);
hold on
plot(T1,P2);
plot(T1,P3);
plot(T1,P4);
plot(T1,P5);
legend('1', '2', '3', '4', '5')