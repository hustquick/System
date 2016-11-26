clear;
number = 10;
eta1 = zeros(1,number);
eta2 = zeros(1,number);
eta_diff = zeros(1,number);
P1 = zeros(number+1, number);
P2 = zeros(number+1, number);
for k = 1 : number
sec1 = SEC(1+k, 'Series');
sec2 = SEC(1+k, 'Parallel');
st1 = Stream;
st1.fluid = char(Const.Fluid(1));
st1.T.v = 1073.15;
st1.p.v = 5e5;
st1.q_m.v = 0.3 * k;

st2 = Stream;
st2.fluid = char(Const.Fluid(2));
st2.T.v = 293.15;
st2.p.v = 1.01325e5;
st2.q_m.v = 0.67;

sec1.st1_i = st1;
sec1.st2_i = st2;
sec1.calculate;
eta1(k) = sec1.eta;

sec2.st1_i = st1;
sec2.st2_i = st2;
sec2.calculate;
eta2(k) = sec2.eta;

eta_diff(k) = (eta1(k)-eta2(k)) ./ eta2(k);
for i = 1 : k + 1
    P1(i,k) = sec1.se(i).P;
    P2(i,k) = sec2.se(i).P;
end
end