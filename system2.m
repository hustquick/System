clear;
% This system is the cascade system with both Stirling cycle and Rankine
% Cycle, without a heat exchanger between the air and the water.
%% Get results matrix
number = 1;
cs = CascadeSystem2.empty(0, number);
ss = SeparateSystem.empty(0, number);
eta_diff = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1:number
%% Connection and State points
cs(k).sea = SEA(3, 30, 'Same');
cs(k).sea.st1_i = cs(k).dca.st_o;
cs(k).dca.st_i = cs(k).sea.st1_o;

cs(k).st1(1) = cs(k).sea.st1_i;
cs(k).st1(2) = cs(k).dca.st_i;

cs(k).tb.st_i = cs(k).sh.st1_o;
cs(k).da.st_i_1 = cs(k).tb.st_o_1;
cs(k).cd.st_i = cs(k).tb.st_o_2;
cs(k).pu1.st_i = cs(k).cd.st_o;
cs(k).sea.st2_i = cs(k).pu1.st_o;
cs(k).da.st_i_2 = cs(k).sea.st2_o;
cs(k).pu2.st_i = cs(k).da.st_o;
cs(k).ph.st1_i = cs(k).pu2.st_o;
cs(k).ev.st1_i = cs(k).ph.st1_o;
cs(k).sh.st1_i = cs(k).ev.st1_o;

cs(k).st2(1) = cs(k).tb.st_i;
cs(k).st2(2) = cs(k).da.st_i_1;
cs(k).st2(3) = cs(k).cd.st_i;
cs(k).st2(4) = cs(k).pu1.st_i;
cs(k).st2(5) = cs(k).sea.st2_i;
cs(k).st2(6) = cs(k).da.st_i_2;
cs(k).st2(7) = cs(k).pu2.st_i;
cs(k).st2(8) = cs(k).ph.st1_i;
cs(k).st2(9) = cs(k).ev.st1_i;
cs(k).st2(10) = cs(k).sh.st1_i;

cs(k).sh.st2_i = cs(k).tca.st_o;
cs(k).ev.st2_i = cs(k).sh.st2_o;
cs(k).ph.st2_i = cs(k).ev.st2_o;
cs(k).tca.st_i = cs(k).ph.st2_o;

cs(k).st3(1) = cs(k).sh.st2_i;
cs(k).st3(2) = cs(k).ev.st2_i;
cs(k).st3(3) = cs(k).ph.st2_i;
cs(k).st3(4) = cs(k).tca.st_i;

%% Design parameters
cs(k).dca.n = 30;

cs(k).dca.dc.amb.I_r = 700;
cs(k).dca.dc.st_i.fluid = char(Const.Fluid(1));
cs(k).dca.dc.st_i.T.v = convtemp(350, 'C', 'K');   % Design parameter
cs(k).dca.dc.st_i.p.v = 5e5;
cs(k).dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

cs(k).tca.tc.amb.I_r = cs(k).dca.dc.amb.I_r;

cs(k).tca.st_o.fluid = char(Const.Fluid(3));
cs(k).tca.st_o.T.v = convtemp(380, 'C', 'K');
cs(k).tca.st_o.p = Pressure(2e6);

cs(k).tb.st_i.fluid = char(Const.Fluid(2));
cs(k).tb.st_i.T.v = convtemp(340, 'C', 'K');
cs(k).tb.st_i.p = Pressure(2.35e6);
cs(k).tb.st_o_2.p = Pressure(1.5e4);

cs(k).ge.P = 4e6;
cs(k).ge.eta = 0.975;

cs(k).da.p = Pressure(1e6);

cs(k).DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

cs(k).sea.n2 = cs(k).dca.n;

%% Work
cs(k).dca.dc.get_q_m();
cs(k).dca.work();
cs(k).da.getP();


% Guess the value of cs(k).tb.st_i.q_m.v
guess = 7.3; % This initial value can be obtained by the power of turbine
options = optimset('Algorithm','levenberg-marquardt','Display','iter');
fsolve(@(x)Calc_SEA_da(x, cs(k)), guess, options);

cs(k).pu2.p = cs(k).tb.st_i.p;
cs(k).pu2.work;

% get q_m_3
cs(k).ph.calcSt1_o();
cs(k).ph.st2_i.T.v = cs(k).ph.st1_o.T.v + cs(k).DeltaT_3_2;
cs(k).sh.st2_i.flowTo(cs(k).ph.st2_i);
cs(k).ph.st2_i.p = cs(k).sh.st2_i.p;
cs(k).ph.st2_i.q_m.v = cs(k).ph.st1_o.q_m.v .* (cs(k).sh.st1_o.h - ...
    cs(k).ph.st1_o.h) ./ (cs(k).sh.st2_i.h - cs(k).ph.st2_i.h);

cs(k).ph.get_imcprs_st2_o();
cs(k).ev.calcSt1_o();
cs(k).ev.get_imcprs_st2_i();

cs(k).sh.get_st1_o();

cs(k).tca.st_i.convergeTo(cs(k).tca.tc.st_i, 1);
cs(k).tca.st_o.convergeTo(cs(k).tca.tc.st_o, 1);
cs(k).tca.tc.calculate;
cs(k).tca.n1 = cs(k).tca.tc.n;
cs(k).tca.n2 = cs(k).tca.st_i.q_m.v ./ cs(k).tca.tc.st_i.q_m.v;
cs(k).tca.eta = cs(k).tca.tc.eta;

T1 = zeros(1,numel(cs(k).st1));
q_m1 = zeros(1,numel(cs(k).st1));
T2 = zeros(1,numel(cs(k).st2));
q_m2 = zeros(1,numel(cs(k).st2));
T3 = zeros(1,numel(cs(k).st2));
q_m3 = zeros(1,numel(cs(k).st3));
T1_i = zeros(1,cs(k).sea.n1);
T1_o = zeros(1,cs(k).sea.n1);
T2_i = zeros(1,cs(k).sea.n1);
T2_o = zeros(1,cs(k).sea.n1);

for i = 1 : numel(cs(k).st1)
    T1(i) = cs(k).st1(i).T.v;
    q_m1(i) = cs(k).st1(i).q_m.v;
end
for i = 1 : numel(cs(k).st2)
    T2(i) = cs(k).st2(i).T.v;
    q_m2(i) = cs(k).st2(i).q_m.v;
end
for i = 1 : numel(cs(k).st3)
    T3(i) = cs(k).st3(i).T.v;
    q_m3(i) = cs(k).st3(i).q_m.v;
end

for i = 1 : cs(k).sea.n1
    T1_i(i) = cs(k).sea.se(i).st1_i.T.v;
    T1_o(i) = cs(k).sea.se(i).st1_o.T.v;
    T2_i(i) = cs(k).sea.se(i).st2_i.T.v;
    T2_o(i) = cs(k).sea.se(i).st2_o.T.v;
end

%% Rankine cycle efficiency and overall efficiency
Q_rankine = cs(k).sea.st2_i.q_m.v .* (cs(k).sea.st2_o.h -  cs(k).sea.st2_i.h) ...
    + cs(k).sh.st1_o.q_m.v .* (cs(k).sh.st1_o.h - cs(k).ph.st1_i.h);
P_rankine = (cs(k).ge.P - cs(k).pu1.P - cs(k).pu2.P) ./ cs(k).ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

cs(k).Q = cs(k).dca.st_o.q_m.v .* (cs(k).dca.st_o.h - cs(k).dca.st_i.h) ./ cs(k).dca.eta ...
    + cs(k).tca.st_o.q_m.v .* (cs(k).tca.st_o.h - cs(k).tca.st_i.h) ./ cs(k).tca.eta;
cs(k).P = cs(k).ge.P + cs(k).sea.P - cs(k).pu1.P - cs(k).pu2.P;
cs(k).eta = cs(k).P ./ cs(k).Q;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss(k) = SeparateSystem;

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
ss(k).dca.n = cs(k).dca.n;
ss(k).dca.dc.amb = cs(k).dca.dc.amb;
ss(k).dca.dc.st_i.fluid = cs(k).dca.dc.st_i.fluid;
ss(k).dca.dc.st_i.T.v = cs(k).dca.dc.st_i.T.v;
ss(k).dca.eta = cs(k).dca.eta;
ss(k).ge.eta = cs(k).ge.eta;
ss(k).tb.st_i.T = cs(k).tb.st_i.T;
ss(k).tb.st_i.p = cs(k).tb.st_i.p;
ss(k).tb.st_o_2.p = cs(k).tb.st_o_2.p;
ss(k).da.p = cs(k).da.p;
ss(k).DeltaT_3_2 = cs(k).DeltaT_3_2;

q_se = cs(k).sea.se(1).P ./ cs(k).sea.se(1).eta;  % Heat absorbed by the first
    % Stirling engine in SEA of cascade sysem
T_H = cs(k).dca.dc.airPipe.T.v - q_se ./ (cs(k).sea.se(1).U_1 .* ...
    cs(k).sea.se(1).A_1);
T_L = 310;  % Parameter of 4-95 MKII engine
T_R = Const.LogMean(T_H, T_L);
e = (T_R - T_L) ./ (T_H - T_L);
eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (ss.se.k -1) ./ log(ss.se.gamma));
P_ss_se = ss.dca.dc.q_tot .* ss.dca.eta .* ss.dca.n .* eta_ss_se;

ss(k).st2(7).T.v = cs(k).st2(8).T.v;
ss(k).st2(7).p = cs(k).st2(8).p;
ss(k).st2(7).q_m.v = cs(k).st2(8).q_m.v .* (cs(k).st2(1).h - cs(k).st2(8).h) ...
    ./ (ss(k).st2(1).h - ss(k).st2(7).h);
ss(k).tb.st_i.q_m = ss(k).st2(7).q_m;

ss(k).st2(2).T.v = cs(k).st2(2).T.v;
ss(k).st2(3).T.v = cs(k).st2(3).T.v;
ss(k).st2(5).T.v = cs(k).st2(5).T.v;
ss(k).st2(6).T.v = cs(k).st2(7).T.v;
ss(k).st2(3).x = cs(k).st2(3).x;
ss(k).st2(4).x = 0;
ss(k).st2(6).x = 0;
ss(k).da.getP();
ss(k).tb.y = (ss(k).st2(6).h - ss(k).st2(5).h) ./ (ss(k).st2(2).h - ss(k).st2(5).h);
ss(k).tb.st_o_1.q_m.v = ss(k).tb.st_i.q_m.v .* ss(k).tb.y;
ss(k).tb.st_o_2.q_m.v = ss(k).tb.st_i.q_m.v .* (1 - ss(k).tb.y);
ss(k).ge.P = ss(k).tb.P .* ss(k).ge.eta;

ss(k).cd.work();
ss(k).pu1.p = ss(k).da.p;
ss(k).pu1.work();

ss(k).da.work(ss(k).tb);
ss(k).pu2.p = ss(k).tb.st_i.p;
ss(k).pu2.work();

ss(k).st2(8).q_m.v = ss(k).st2(7).q_m.v;
ss(k).st2(8).T.v = cs(k).st2(9).T.v;
ss(k).st2(9).q_m.v = ss(k).st2(8).q_m.v;
ss(k).st2(9).T.v = cs(k).st2(10).T.v;

% Q_ss_rankine = ss(k).sh.st1_o.q_m.v .* (ss(k).sh.st1_o.h - ss(k).ph.st1_i.h);
% 
% P_ss_rankine = (ss(k).ge.P - ss(k).pu1.P - cs(k).pu2.P) ./ ss(k).ge.eta;
% eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

ss(k).Q = ss(k).dca.dc.q_tot .* ss(k).dca.n + cs(k).tca.st_o.q_m.v .* ...
    (cs(k).tca.st_o.h - cs(k).tca.st_i.h) ./ cs(k).tca.eta;
ss(k).P = ss(k).ge.P + P_ss_se - ss(k).pu1.P - ss(k).pu2.P;
ss(k).eta = ss(k).P ./ ss(k).Q;
%% Comparison
eta_diff(k) = (cs(k).eta - ss(k).eta) ./ ss(k).eta;
ratio(k) = cs(k).sea.P ./ cs(k).ge.P;
used(k) = (cs(k).sea.P ./ cs(k).sea.eta) ./ (cs(k).dca.n .* cs(k).dca.dc.q_tot);
end
