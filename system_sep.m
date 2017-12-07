clear;
% This is the system to demenstrate the advantage of separate SEP
% ss is the traditional system
% ss1 is the system using MERS
%% Get results matrix
number = 3;
ss = SeparateSystem.empty(0, number);
ss1 = SeparateSystem.empty(0, number);
eta_diff = zeros(1,number);
I_ph = zeros(1,number);
I_ev = zeros(1,number);
I_sh = zeros(1,number);
I_ph1 = zeros(1,number);
I_ev1 = zeros(1,number);
I_sh1 = zeros(1,number);
I_total = zeros(1,number);
I_total1 = zeros(1,number);
eta_T= 0;
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
%% Multi-stage exergy redcution system Part
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

% key differences
T_3_min = ss(k).ph.st1_o.T.v + ss(k).DeltaT_3_2;
T_3_max = ss(k).ph.st2_i.T.v + (ss(k).sh.st1_o.T.v + ss(k).DeltaT_3_2 ...
    - ss(k).ph.st2_i.T.v) .* (ss(k).st3(2).T.v - ss(k).st3(3).T.v) ...
    ./ (ss(k).st3(1).T.v - ss(k).st3(3).T.v);
Delta_T_3 = T_3_max - T_3_min;
ss1(k).tca3.st_i.T.v = T_3_min + eta_T + (k-1) .* Delta_T_3 / 2;
% ss1(k).tca3.st_i.T.v = (ss(k).ph.st2_i.T.v + (ss(k).sh.st1_o.T.v + ss(k).DeltaT_3_2 ...
%     - ss(k).ph.st2_i.T.v) * (ss(k).st3(2).T.v - ss(k).st3(3).T.v) ...
%     / (ss(k).st3(1).T.v - ss(k).st3(3).T.v) + ss(k).ph.st1_o.T.v + ss(k).DeltaT_3_2) / 2;
ss1(k).tca3.st_o.T.v = ss(k).sh.st1_o.T.v + ss(k).DeltaT_3_2;
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

%% Calculate the exergy loss
I_ph(k) = ss(k).tca.tc.amb.T.v .* (ss(k).ph.st1_o.q_m.v .* ss(k).ph.st1_o.s...
    + ss(k).ph.st2_o.q_m.v .* ss(k).ph.st2_o.s - ...
    ss(k).ph.st1_i.q_m.v .* ss(k).ph.st1_i.s - ...
    ss(k).ph.st2_i.q_m.v .* ss(k).ph.st2_i.s);
I_ev(k) = ss(k).tca.tc.amb.T.v .* (ss(k).ev.st1_o.q_m.v .* ss(k).ev.st1_o.s...
    + ss(k).ev.st2_o.q_m.v .* ss(k).ev.st2_o.s - ...
    ss(k).ev.st1_i.q_m.v .* ss(k).ev.st1_i.s - ...
    ss(k).ev.st2_i.q_m.v .* ss(k).ev.st2_i.s);
I_sh(k) = ss(k).tca.tc.amb.T.v .* (ss(k).sh.st1_o.q_m.v .* ss(k).sh.st1_o.s...
    + ss(k).sh.st2_o.q_m.v .* ss(k).sh.st2_o.s - ...
    ss(k).sh.st1_i.q_m.v .* ss(k).sh.st1_i.s - ...
    ss(k).sh.st2_i.q_m.v .* ss(k).sh.st2_i.s);
I_total(k) = I_ph(k) + I_ev(k) + I_sh(k);

I_ph1(k) = ss1(k).tca.tc.amb.T.v .* (ss1(k).ph.st1_o.q_m.v .* ss1(k).ph.st1_o.s...
    + ss1(k).ph.st2_o.q_m.v .* ss1(k).ph.st2_o.s - ...
    ss1(k).ph.st1_i.q_m.v .* ss1(k).ph.st1_i.s - ...
    ss1(k).ph.st2_i.q_m.v .* ss1(k).ph.st2_i.s);
I_ev1(k) = ss1(k).tca.tc.amb.T.v .* (ss1(k).ev.st1_o.q_m.v .* ss1(k).ev.st1_o.s...
    + ss1(k).ev.st2_o.q_m.v .* ss1(k).ev.st2_o.s - ...
    ss1(k).ev.st1_i.q_m.v .* ss1(k).ev.st1_i.s - ...
    ss1(k).ev.st2_i.q_m.v .* ss1(k).ev.st2_i.s);
I_sh1(k) = ss1(k).tca.tc.amb.T.v .* (ss1(k).sh.st1_o.q_m.v .* ss1(k).sh.st1_o.s...
    + ss1(k).sh.st2_o.q_m.v .* ss1(k).sh.st2_o.s - ...
    ss1(k).sh.st1_i.q_m.v .* ss1(k).sh.st1_i.s - ...
    ss1(k).sh.st2_i.q_m.v .* ss1(k).sh.st2_i.s);
I_total1(k) = I_ph1(k) + I_ev1(k) + I_sh1(k);
end
% Heat exchanged in the evaporator
Q_ph = ss(1).ph.st1_o.q_m.v * (ss(1).ph.st1_o.h - ss(1).ph.st1_i.h);
Q_sh = ss(1).sh.st1_o.q_m.v * (ss(1).sh.st1_o.h - ss(1).sh.st1_i.h);
Q_ev = ss(1).ev.st1_o.q_m.v * (ss(1).ev.st1_o.h - ss(1).ev.st1_i.h);
I_ev_inf = ss(1).tca.tc.amb.T.v .* ss(k).DeltaT_3_2 .* Q_ev ./ ...
    (ss(1).ev.st1_o.T.v .* (ss(1).ev.st1_o.T.v + ss(k).DeltaT_3_2));
I_ev1(1) = I_ev_inf;
I_total1(1) = I_ph1(1) + I_ev_inf + I_sh1(1);