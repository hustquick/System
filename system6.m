clear;
% This is the system to demenstrate the advantage of separate SEP
%% Get results matrix
number = 1;
ss = SeparateSystem.empty(0, number);
ss1 = SeparateSystem.empty(0, number);
eta_diff = zeros(1,number);
for k = 1:number
ss(k) = SeparateSystem;
%% Connection and State points
ss(k).tb.st_i = ss(k).sh.st1_o;
ss(k).da.st_i_1 = ss(k).tb.st_o_1;
ss(k).cd.st_i = ss(k).tb.st_o_2;
ss(k).pu1.st_i = ss(k).cd.st_o;
ss(k).da.st_i_2 = ss(k).pu1.st_o;
ss(k).pu2.st_i = ss(k).da.st_o;
ss(k).ph.st1_i = ss(k).pu2.st_o;
ss(k).ev.st1_i = ss(k).ph.st1_o;
ss(k).sh.st1_i = ss(k).ev.st1_o;

ss(k).st2(1) = ss(k).tb.st_i;
ss(k).st2(2) = ss(k).da.st_i_1;
ss(k).st2(3) = ss(k).cd.st_i;
ss(k).st2(4) = ss(k).pu1.st_i;
ss(k).st2(5) = ss(k).da.st_i_2;
ss(k).st2(6) = ss(k).pu2.st_i;
ss(k).st2(7) = ss(k).ph.st1_i;
ss(k).st2(8) = ss(k).ev.st1_i;
ss(k).st2(9) = ss(k).sh.st1_i;

ss(k).sh.st2_i = ss(k).tca.st_o;
ss(k).ev.st2_i = ss(k).sh.st2_o;
ss(k).ph.st2_i = ss(k).ev.st2_o;
ss(k).tca.st_i = ss(k).ph.st2_o;

ss(k).st3(1) = ss(k).sh.st2_i;
ss(k).st3(2) = ss(k).ev.st2_i;
ss(k).st3(3) = ss(k).ph.st2_i;
ss(k).st3(4) = ss(k).tca.st_i;

for i = 1 : 9
    ss(k).st2(i).fluid = char(Const.Fluid(2));
end
%% Design parameters
ss(k).tca.tc.amb.I_r = 700;

ss(k).tca.st_o.fluid = char(Const.Fluid(3));
ss(k).tca.st_o.T.v = convtemp(380, 'C', 'K');
ss(k).tca.st_o.p.v = 2e6;

ss(k).tb.st_i.fluid = char(Const.Fluid(2));
ss(k).tb.st_i.T.v = convtemp(340, 'C', 'K');
ss(k).tb.st_i.p.v = 2.35e6;
ss(k).tb.st_o_2.p.v = 1.5e4;

ss(k).ge.P = 4e6;
ss(k).ge.eta = 0.975;

ss(k).da.p = Pressure(1e6);

ss(k).DeltaT_3_2 = 15;          % Minimun temperature difference 
%   between oil and water

%% Work
% ss(k).tb.work(ss(k).ge);
ss(k).cd.work();
ss(k).pu1.p = ss(k).da.p;
ss(k).pu1.work();
ss(k).da.get_p();
st1 = Stream;
st1.p = ss(k).tb.st_o_1.p;
% ss(k).tb.st_i.q_m.v = 1;
ss(k).tb.flowInTurbine(ss(k).tb.st_i, st1, ...
    ss(k).tb.st_o_1.p);
ss(k).tb.st_o_1.T = st1.T;
ss(k).tb.y = (ss(k).da.st_o.h - ss(k).da.st_i_2.h) ./ ...
    (ss(k).da.st_i_1.h - ss(k).da.st_i_2.h);

st2 = Stream;
st2.p = ss(k).tb.st_o_2.p;
% ss(k).tb.st_i.q_m.v = 1;
ss(k).tb.flowInTurbine(ss(k).tb.st_i, st2, ...
    ss(k).tb.st_o_2.p);
ss(k).tb.st_o_2.x = st2.x;
ss(k).tb.st_i.q_m.v = ss(k).tb.get_q_m(ss(k).ge);
ss(k).tb.st_o_1.q_m.v = ss(k).tb.y .* ss(k).tb.st_i.q_m.v;
ss(k).tb.st_o_2.q_m.v = (1 - ss(k).tb.y) .* ss(k).tb.st_i.q_m.v;
ss(k).da.work(ss(k).tb);
ss(k).pu2.p = ss(k).tb.st_i.p;
ss(k).pu2.work;

% get q_m_3
ss(k).ph.calcSt1_o();
ss(k).ph.st2_i.T.v = ss(k).ph.st1_o.T.v + ss(k).DeltaT_3_2;
ss(k).sh.st2_i.flowTo(ss(k).ph.st2_i);
ss(k).ph.st2_i.p = ss(k).sh.st2_i.p;
ss(k).ph.st2_i.q_m.v = ss(k).ph.st1_o.q_m.v .* (ss(k).sh.st1_o.h - ...
    ss(k).ph.st1_o.h) ./ (ss(k).sh.st2_i.h - ss(k).ph.st2_i.h);

ss(k).ph.get_imcprs_st2_o();
ss(k).ev.calcSt1_o();
ss(k).ev.get_imcprs_st2_i();

ss(k).sh.get_st1_o();

ss(k).tca.st_i.convergeTo(ss(k).tca.tc.st_i, 1);
ss(k).tca.st_o.convergeTo(ss(k).tca.tc.st_o, 1);
ss(k).tca.tc.calculate;
ss(k).tca.n1 = ss(k).tca.tc.n;
ss(k).tca.n2 = ss(k).tca.st_i.q_m.v ./ ss(k).tca.tc.st_i.q_m.v;
ss(k).tca.eta = ss(k).tca.tc.eta;

%% Rankine cycle efficiency and overall efficiency
Q_rankine = ss(k).sh.st1_o.q_m.v .* (ss(k).sh.st1_o.h - ss(k).ph.st1_i.h);
P_rankine = (ss(k).ge.P - ss(k).pu1.P - ss(k).pu2.P) ./ ss(k).ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

ss(k).Q = ss(k).tca.st_o.q_m.v .* (ss(k).tca.st_o.h - ss(k).tca.st_i.h) ...
    ./ ss(k).tca.eta;
ss(k).P = ss(k).ge.P - ss(k).pu1.P - ss(k).pu2.P;
ss(k).eta = ss(k).P ./ ss(k).Q;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss1(k) = SeparateSystem;

for i = 1 : 9
    ss1(k).st2(i) = ss(k).st2(i);
end
ss1(k).sh.st1_o = ss1(k).st2(1);
ss1(k).tb.st_o_1 = ss1(k).st2(2);
ss1(k).tb.st_o_2 = ss1(k).st2(3);
ss1(k).cd.st_o = ss1(k).st2(4);
ss1(k).pu1.st_o = ss1(k).st2(5);
ss1(k).da.st_o = ss1(k).st2(6);
ss1(k).pu2.st_o = ss1(k).st2(7);
ss1(k).ph.st1_o = ss1(k).st2(8);
ss1(k).ev.st1_o = ss1(k).st2(9);

ss1(k).tb.st_i = ss1(k).sh.st1_o;
ss1(k).da.st_i_1 = ss1(k).tb.st_o_1;
ss1(k).cd.st_i = ss1(k).tb.st_o_2;
ss1(k).pu1.st_i = ss1(k).cd.st_o;
ss1(k).da.st_i_2 = ss1(k).pu1.st_o;
ss1(k).pu2.st_i = ss1(k).da.st_o;
ss1(k).ph.st1_i = ss1(k).pu2.st_o;
ss1(k).ev.st1_i = ss1(k).ph.st1_o;
ss1(k).sh.st1_i = ss1(k).ev.st1_o;

ss1(k).sh.st2_i = ss1(k).tca3.st_o;
ss1(k).tca3.st_i = ss1(k).sh.st2_o;
ss1(k).ev.st2_i = ss1(k).tca2.st_o;
ss1(k).tca2.st_i = ss1(k).ev.st2_o;
ss1(k).ph.st2_i = ss1(k).tca1.st_o;
ss1(k).tca1.st_i = ss1(k).ph.st2_o;

ss1(k).st3(1) = ss1(k).sh.st2_i;
ss1(k).st3(2) = ss1(k).tca3.st_i;
ss1(k).st3(3) = ss1(k).ev.st2_i;
ss1(k).st3(4) = ss1(k).tca2.st_i;
ss1(k).st3(5) = ss1(k).ph.st2_i;
ss1(k).st3(6) = ss1(k).tca1.st_i;

ss1(k).tca3.tc.amb.I_r = ss(k).tca.tc.amb.I_r;
ss1(k).tca2.tc.amb.I_r = ss(k).tca.tc.amb.I_r;
ss1(k).tca1.tc.amb.I_r = ss(k).tca.tc.amb.I_r;
ss1(k).tca3.st_i.fluid = ss(k).tca.st_i.fluid;
ss1(k).tca3.st_i.flowTo(ss1(k).tca3.st_o);
ss1(k).tca2.st_i.fluid = ss(k).tca.st_i.fluid;
ss1(k).tca2.st_i.flowTo(ss1(k).tca2.st_o);
ss1(k).tca1.st_i.fluid = ss(k).tca.st_i.fluid;
ss1(k).tca1.st_i.flowTo(ss1(k).tca1.st_o);

ss1(k).tca3.st_i.p = ss(k).tca.st_i.p;
ss1(k).tca3.st_o.p = ss(k).tca.st_i.p;
ss1(k).tca2.st_i.p = ss(k).tca.st_i.p;
ss1(k).tca2.st_o.p = ss(k).tca.st_i.p;
ss1(k).tca1.st_i.p = ss(k).tca.st_i.p;
ss1(k).tca1.st_o.p = ss(k).tca.st_i.p;
ss1(k).tca3.st_i.T.v = ss(k).sh.st2_i.T.v + ss(k).sh.st1_i.T.v ...
    - ss(k).sh.st1_o.T.v;
ss1(k).tca3.st_o.T.v = ss(k).sh.st2_i.T.v;
ss1(k).tca2.st_i.T.v = ss(k).ev.st2_o.T.v;
ss1(k).tca2.st_o.T.v = ss1(k).tca3.st_i.T.v;
ss1(k).tca1.st_i.T.v = ss(k).ph.st2_i.T.v + ss(k).ph.st1_i.T.v ...
    -ss(k).ph.st1_o.T.v;
ss1(k).tca1.st_o.T.v = ss(k).ph.st2_i.T.v;

ss1(k).sh.get_q_m_2();
ss1(k).ev.get_q_m_2();
ss1(k).ph.get_q_m_2();

ss1(k).tca3.st_i.convergeTo(ss1(k).tca3.tc.st_i, 1);
ss1(k).tca3.st_o.convergeTo(ss1(k).tca3.tc.st_o, 1);
ss1(k).tca3.tc.calculate;
ss1(k).tca3.n1 = ss1(k).tca3.tc.n;
ss1(k).tca3.n2 = ss1(k).tca3.st_i.q_m.v ./ ss1(k).tca3.tc.st_i.q_m.v;
ss1(k).tca3.eta = ss1(k).tca3.tc.eta;

ss1(k).tca2.st_i.convergeTo(ss1(k).tca2.tc.st_i, 1);
ss1(k).tca2.st_o.convergeTo(ss1(k).tca2.tc.st_o, 1);
ss1(k).tca2.tc.calculate;
ss1(k).tca2.n1 = ss1(k).tca2.tc.n;
ss1(k).tca2.n2 = ss1(k).tca2.st_i.q_m.v ./ ss1(k).tca2.tc.st_i.q_m.v;
ss1(k).tca2.eta = ss1(k).tca2.tc.eta;

ss1(k).tca1.st_i.convergeTo(ss1(k).tca1.tc.st_i, 1);
ss1(k).tca1.st_o.convergeTo(ss1(k).tca1.tc.st_o, 1);
ss1(k).tca1.tc.calculate;
ss1(k).tca1.n1 = ss1(k).tca1.tc.n;
ss1(k).tca1.n2 = ss1(k).tca1.st_i.q_m.v ./ ss1(k).tca1.tc.st_i.q_m.v;
ss1(k).tca1.eta = ss1(k).tca1.tc.eta;

% Q_ss_rankine = ss1(k).sh.st1_o.q_m.v .* (ss1(k).sh.st1_o.h - ss1(k).ph.st1_i.h);
% 
% P_ss_rankine = (ss(k).ge.P - ss(k).pu1.P - ss(k).pu2.P) ./ ss(k).ge.eta;
% eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

ss1(k).Q = ss1(k).tca1.st_i.q_m.v .* (ss1(k).tca1.st_o.h - ss1(k).tca1.st_i.h) ./ ss1(k).tca1.eta + ...
    ss1(k).tca2.st_i.q_m.v .* (ss1(k).tca2.st_o.h - ss1(k).tca2.st_i.h) ./ ss1(k).tca2.eta + ...
    ss1(k).tca3.st_i.q_m.v .* (ss1(k).tca3.st_o.h - ss1(k).tca3.st_i.h) ./ ss1(k).tca3.eta;
ss1(k).P = ss(k).ge.P - ss(k).pu1.P - ss(k).pu2.P;
ss1(k).eta = ss1(k).P ./ ss1(k).Q;
%% Comparison
eta_diff(k) = (ss1(k).eta - ss(k).eta) ./ ss(k).eta;
end