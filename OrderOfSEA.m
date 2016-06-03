clear;
number = 10;
n1 = 2;

T1_i = zeros(number,n1);
T1_o = zeros(number,n1);
T2_i = zeros(number,n1);
T2_o = zeros(number,n1);
eta = zeros(number,n1);
eta_a = zeros(number,1);

for k = 1 : number
sea = SEA(n1, 'Same');
sea.n_se = 150;

st1_i = Stream;
st2_i = Stream;

st1_i.fluid = char(Const.Fluid(1));
% st1_i.q_m.v = 2.6678;
st1_i.q_m.v = 2 * k;
st1_i.T.v = 1073.15;
st1_i.p.v = 5e5;
st1_o = st1_i.flow();

st2_i.fluid = char(Const.Fluid(2));
st2_i.q_m.v = 6.0764;
% st2_i.q_m.v = 0.1 * 10^(0.2 * k);
st2_i.T.v = 327.2;
st2_i.p.v = 1e6;
st2_o = st2_i.flow();

sea.st1_i = st1_i;
sea.st2_i = st2_i;
sea.st1_o = st1_o;
sea.st2_o = st2_o;

sea.calculate();

    for i = 1 : sea.n1
        T1_i(k,i) = sea.se(i).st1_i.T.v;
        T1_o(k,i) = sea.se(i).st1_o.T.v;
        T2_i(k,i) = sea.se(i).st2_i.T.v;
        T2_o(k,i) = sea.se(i).st2_o.T.v;
        eta(k,i) = sea.se(i).eta;
    end
eta_a(k) = sea.eta;
end