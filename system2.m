clear;
%% Get results matrix
number = 1;
eta_diff = zeros(1,number);
eta_cs_r = zeros(1,number);
eta_sea = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1:number
cs = CascadeSystem;
%% Connection and State points
cs.sea = SEA(3, 30, 'Same');
cs.sea.st1_i = cs.dca.st_o;
cs.dca.st_i = cs.sea.st1_o;

cs.st1(1) = cs.sea.st1_i;
cs.st1(2) = cs.dca.st_i;

cs.tb.st_i = cs.sh.st1_o;
cs.da.st_i_1 = cs.tb.st_o_1;
cs.cd.st_i = cs.tb.st_o_2;
cs.pu1.st_i = cs.cd.st_o;
cs.sea.st2_i = cs.pu1.st_o;
cs.da.st_i_2 = cs.sea.st2_o;
cs.pu2.st_i = cs.da.st_o;
cs.ph.st1_i = cs.pu2.st_o;
cs.ev.st1_i = cs.ph.st1_o;
cs.sh.st1_i = cs.ev.st1_o;

cs.st2(1) = cs.tb.st_i;
cs.st2(2) = cs.da.st_i_1;
cs.st2(3) = cs.cd.st_i;
cs.st2(4) = cs.pu1.st_i;
cs.st2(5) = cs.sea.st2_i;
cs.st2(6) = cs.da.st_i_2;
cs.st2(7) = cs.pu2.st_i;
cs.st2(8) = cs.ph.st1_i;
cs.st2(9) = cs.ev.st1_i;
cs.st2(10) = cs.sh.st1_i;

cs.sh.st2_i = cs.tca.st_o;
cs.ev.st2_i = cs.sh.st2_o;
cs.ph.st2_i = cs.ev.st2_o;
cs.tca.st_i = cs.ph.st2_o;

cs.st3(1) = cs.sh.st2_i;
cs.st3(2) = cs.ev.st2_i;
cs.st3(3) = cs.ph.st2_i;
cs.st3(4) = cs.tca.st_i;

%% Design parameters
cs.dca.n = 30;

cs.dca.dc.amb.I_r = 330 + k * 70;
cs.dca.dc.st_i.fluid = char(Const.Fluid(1));
cs.dca.dc.st_i.T.v = convtemp(350, 'C', 'K');   % Design parameter
cs.dca.dc.st_i.p.v = 5e5;
cs.dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

cs.tca.tc.amb.I_r = cs.dca.dc.amb.I_r;

cs.tca.st_o.fluid = char(Const.Fluid(3));
cs.tca.st_o.T.v = convtemp(380, 'C', 'K');
cs.tca.st_o.p.v = 2e6;

cs.tb.st_i.fluid = char(Const.Fluid(2));
cs.tb.st_i.T.v = convtemp(340, 'C', 'K');
cs.tb.st_i.p.v = 2.35e6;
cs.tb.st_o_2.p.v = 1.5e4;

cs.ge.P = 4e6;
cs.ge.eta = 0.975;

cs.da.p.v = 1e6;

cs.DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

cs.sea.n2 = cs.dca.n;

%% Work
cs.dca.dc.get_q_m();
cs.dca.work();
cs.da.getP();


% Guess the value of cs.tb.st_i.q_m.v
guess = 7.3; % This initial value can be obtained by the power of turbine
options = optimset('Algorithm','levenberg-marquardt','Display','iter');
fsolve(@(x)Calc_SEA_da(x, cs), guess, options);

cs.pu2.p = cs.tb.st_i.p;
cs.pu2.work;

% get q_m_3
cs.ph.calcSt1_o();
cs.ph.st2_i.T.v = cs.ph.st1_o.T.v + cs.DeltaT_3_2;
cs.sh.st2_i.flowTo(cs.ph.st2_i);
cs.ph.st2_i.p = cs.sh.st2_i.p;
cs.ph.st2_i.q_m.v = cs.ph.st1_o.q_m.v .* (cs.sh.st1_o.h - ...
    cs.ph.st1_o.h) ./ (cs.sh.st2_i.h - cs.ph.st2_i.h);

cs.ph.get_imcprs_st2_o();
cs.ev.calcSt1_o();
cs.ev.get_imcprs_st2_i();

cs.sh.get_st1_o();

cs.tca.st_i.convergeTo(cs.tca.tc.st_i, 1);
cs.tca.st_o.convergeTo(cs.tca.tc.st_o, 1);
cs.tca.tc.calculate;
cs.tca.n1 = cs.tca.tc.n;
cs.tca.n2 = cs.tca.st_i.q_m.v ./ cs.tca.tc.st_i.q_m.v;
cs.tca.eta = cs.tca.tc.eta;

T1 = zeros(1,3);
q_m1 = zeros(1,3);
T2 = zeros(1,11);
q_m2 = zeros(1,11);
T3 = zeros(1,11);
q_m3 = zeros(1,3);
T1_i = zeros(1,cs.sea.n1);
T1_o = zeros(1,cs.sea.n1);
T2_i = zeros(1,cs.sea.n1);
T2_o = zeros(1,cs.sea.n1);

for i = 1 : numel(cs.st1)
    T1(i) = cs.st1(i).T.v;
    q_m1(i) = cs.st1(i).q_m.v;
end
for i = 1 : numel(cs.st2)
    T2(i) = cs.st2(i).T.v;
    q_m2(i) = cs.st2(i).q_m.v;
end
for i = 1 : numel(cs.st3)
    T3(i) = cs.st3(i).T.v;
    q_m3(i) = cs.st3(i).q_m.v;
end

for i = 1 : cs.sea.n1
    T1_i(i) = cs.sea.se(i).st1_i.T.v;
    T1_o(i) = cs.sea.se(i).st1_o.T.v;
    T2_i(i) = cs.sea.se(i).st2_i.T.v;
    T2_o(i) = cs.sea.se(i).st2_o.T.v;
end

%% Rankine cycle efficiency and overall efficiency
Q_rankine = cs.sea.st2_i.q_m.v .* (cs.sea.st2_o.h -  cs.sea.st2_i.h) ...
    + cs.sh.st1_o.q_m.v .* (cs.sh.st1_o.h - cs.ph.st1_i.h);
P_rankine = (cs.ge.P - cs.pu1.P - cs.pu2.P) ./ cs.ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_cs = cs.dca.st_o.q_m.v .* (cs.dca.st_o.h - cs.dca.st_i.h) ./ cs.dca.eta ...
    + cs.tca.st_o.q_m.v .* (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
P_cs = cs.ge.P + cs.sea.P - cs.pu1.P - cs.pu2.P;
eta_cs = P_cs ./ Q_cs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss = SeparateSystem;

ss.tb.st_i = ss.sh.st1_o;
ss.da.st_i_1 = ss.tb.st_o_1;
ss.cd.st_i = ss.tb.st_o_2;
ss.pu1.st_i = ss.cd.st_o;
ss.da.st_i_2 = ss.pu1.st_o;
ss.pu2.st_i = ss.da.st_o;
ss.ph.st1_i = ss.pu2.st_o;
ss.ev.st1_i = ss.ph.st1_o;
ss.sh.st1_i = ss.ev.st1_o;

ss.st2(1) = ss.tb.st_i;
ss.st2(2) = ss.da.st_i_1;
ss.st2(3) = ss.cd.st_i;
ss.st2(4) = ss.pu1.st_i;
ss.st2(5) = ss.da.st_i_2;
ss.st2(6) = ss.pu2.st_i;
ss.st2(7) = ss.ph.st1_i;
ss.st2(8) = ss.ev.st1_i;
ss.st2(9) = ss.sh.st1_i;

ss.sh.st2_i = ss.tca.st_o;
ss.ev.st2_i = ss.sh.st2_o;
ss.ph.st2_i = ss.ev.st2_o;
ss.tca.st_i = ss.ph.st2_o;

ss.st3(1) = ss.sh.st2_i;
ss.st3(2) = ss.ev.st2_i;
ss.st3(3) = ss.ph.st2_i;
ss.st3(4) = ss.tca.st_i;

for i = 1 : 9
    ss.st2(i).fluid = char(Const.Fluid(2));
end

%% Design parameters
ss.dca.n = cs.dca.n;
ss.dca.dc.amb = cs.dca.dc.amb;
ss.dca.dc.st_i.fluid = cs.dca.dc.st_i.fluid;
ss.dca.dc.st_i.T.v = cs.dca.dc.st_i.T.v;
ss.dca.eta = cs.dca.eta;
ss.ge.eta = cs.ge.eta;
ss.tb.st_i.T = cs.tb.st_i.T;
ss.tb.st_i.p = cs.tb.st_i.p;
ss.tb.st_o_2.p = cs.tb.st_o_2.p;
ss.da.p = cs.da.p;
ss.DeltaT_3_2 = cs.DeltaT_3_2;

q_se = cs.sea.se(1).P ./ cs.sea.se(1).eta;  % Heat absorbed by the first
    % Stirling engine in SEA of cascade sysem
T_H = cs.dca.dc.airPipe.T.v - q_se ./ (cs.sea.se(1).U_1 .* ...
    cs.sea.se(1).A_1);
T_L = 310;  % Parameter of 4-95 MKII engine
T_R = Const.LogMean(T_H, T_L);
e = (T_R - T_L) ./ (T_H - T_L);
eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (ss.se.k -1) ./ log(ss.se.gamma));
P_ss_se = ss.dca.dc.q_tot .* ss.dca.eta .* ss.dca.n .* eta_ss_se;

ss.st2(7).T.v = cs.st2(8).T.v;
ss.st2(7).p = cs.st2(8).p;
ss.st2(7).q_m.v = cs.st2(8).q_m.v .* (cs.st2(1).h - cs.st2(8).h) ...
    ./ (ss.st2(1).h - ss.st2(7).h);
ss.tb.st_i.q_m = ss.st2(7).q_m;

ss.st2(2).T.v = cs.st2(2).T.v;
ss.st2(3).T.v = cs.st2(3).T.v;
ss.st2(5).T.v = cs.st2(5).T.v;
ss.st2(6).T.v = cs.st2(7).T.v;
ss.st2(3).x = cs.st2(3).x;
ss.st2(4).x = 0;
ss.st2(6).x = 0;
ss.da.getP();
ss.tb.y = (ss.st2(6).h - ss.st2(5).h) ./ (ss.st2(2).h - ss.st2(5).h);
ss.tb.st_o_1.q_m.v = ss.tb.st_i.q_m.v .* ss.tb.y;
ss.tb.st_o_2.q_m.v = ss.tb.st_i.q_m.v .* (1 - ss.tb.y);
ss.ge.P = ss.tb.P .* ss.ge.eta;

ss.cd.work();
ss.pu1.p = ss.da.p;
ss.pu1.work();

ss.da.work(ss.tb);
ss.pu2.p = ss.tb.st_i.p;
ss.pu2.work();

ss.st2(8).q_m.v = ss.st2(7).q_m.v;
ss.st2(8).T.v = cs.st2(9).T.v;
ss.st2(9).q_m.v = ss.st2(8).q_m.v;
ss.st2(9).T.v = cs.st2(10).T.v;

Q_ss_rankine = ss.sh.st1_o.q_m.v .* (ss.sh.st1_o.h - ss.ph.st1_i.h);

P_ss_rankine = (ss.ge.P - ss.pu1.P - cs.pu2.P) ./ ss.ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

Q_ss = ss.dca.dc.q_tot .* ss.dca.n + cs.tca.st_o.q_m.v .* ...
    (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
P_ss = ss.ge.P + P_ss_se - ss.pu1.P - ss.pu2.P;
eta_ss = P_ss ./ Q_ss;
%% Comparison
eta_diff(k) = (eta_cs - eta_ss) ./ eta_ss;
eta_cs_r(k) = eta_cs;
eta_sea(k) = cs.sea.eta;
ratio(k) = cs.sea.P ./ cs.ge.P;
used(k) = (cs.sea.P ./ cs.sea.eta) ./ (cs.dca.n .* cs.dca.dc.q_tot);
end