clear;
% This system is the cascade system for demenstration.
%% Get results matrix
number = 1;
eta_diff = zeros(1,number);
eta_hs_r = zeros(1,number);
eta_sea = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1 : number
hs = HeatSystem;
hs.sec = SEC(3, 'Series');
%% Connection and State points
hs.sec.st1_i = hs.dca.st_o;
hs.sh.st2_i = hs.sec.st1_o;
hs.ev.st2_i = hs.sh.st2_o;
hs.ph.st2_i = hs.ev.st2_o;
hs.tca.st_i = hs.ph.st2_o;
hs.dca.st_i = hs.tca.st_o;
hs.sec.st2_i = hs.st2;      % Cooling water stream for each Stirling engine

hs.st1(1) = hs.sec.st1_i;
hs.st1(2) = hs.sh.st2_i;
hs.st1(3) = hs.ev.st2_i;
hs.st1(4) = hs.ph.st2_i;
hs.st1(5) = hs.tca.st_i;
hs.st1(6) = hs.dca.st_i;

hs.otb.st_i = hs.sh.st1_o;
hs.he.st1_i = hs.otb.st_o;
hs.cd.st_i = hs.he.st1_o;
hs.pu.st_i = hs.cd.st_o;
hs.he.st2_i = hs.pu.st_o;
hs.ph.st1_i = hs.he.st2_o;
hs.ev.st1_i = hs.ph.st1_o;
hs.sh.st1_i = hs.ev.st1_o;

hs.st4(1) = hs.otb.st_i;
hs.st4(2) = hs.he.st1_i;
hs.st4(3) = hs.cd.st_i;
hs.st4(4) = hs.pu.st_i;
hs.st4(5) = hs.he.st2_i;
hs.st4(6) = hs.ph.st1_i;
hs.st4(7) = hs.ev.st1_i;
hs.st4(8) = hs.sh.st1_i;
%% Design parameters
hs.dca.n = 3;
hs.dca.dc.amb.I_r = 400;
% hs.dca.dc.amb.I_r = 300 + 70 * k;
hs.dca.dc.st_i.fluid = char(Const.Fluid(1));
hs.dca.dc.st_i.T.v = convtemp(470, 'C', 'K');
hs.dca.dc.st_i.p.v = 5e5;
hs.dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

hs.tca.tc.amb.I_r = hs.dca.dc.amb.I_r;
hs.tca.st_i.fluid = char(Const.Fluid(3));
% hs.tca.st_i.T.v = convtemp(200, 'C', 'K');

hs.otb.fluid_d = char(Const.Fluid(4));
hs.otb.T_s_d.v = convtemp(300, 'C', 'K');
hs.otb.p_s_d = 2.8842e6;
hs.otb.T_c_d.v = convtemp(228.85, 'C', 'K');
hs.otb.p_c_d = 0.3605e6;

hs.otb.st_i.fluid = hs.otb.fluid_d;
hs.otb.st_i.T.v = convtemp(300, 'C', 'K');
hs.otb.st_i.p.v = 2.8842e6;
hs.otb.st_o.p.v = 0.3605e6;

% hs.otb.fluid_d = char(Const.Fluid(5));
% hs.otb.T_s_d.v = convtemp(141.152, 'C', 'K');
% hs.otb.p_s_d = 1e6;
% hs.otb.T_c_d.v = convtemp(91.35, 'C', 'K');
% hs.otb.p_c_d = 0.167e6;
% hs.otb.st_i.fluid = hs.otb.fluid_d;
% hs.otb.st_i.T.v = convtemp(141.152, 'C', 'K');
% hs.otb.st_i.p = 1e6;
% hs.otb.st_o.p = 0.167e6;

hs.ge.eta = 0.975;

DeltaT_1_2 = 15;
hs.DeltaT_1_4 = 15;          % Minimun temperature difference between air
%and water

% Cooling water stream for each Stirling engine
hs.st2.fluid = char(Const.Fluid(2));
hs.st2.T.v = 293.15;
hs.st2.p.v = 1.01325e5;
hs.st2.q_m.v = 0.67;
%% Work
% hs.ge.P = 50e3;     % Will be automatically corrected
hs.dca.dc.get_q_m();
hs.dca.work();

hs.sec.calculate();

hs.otb.work(hs.ge);

hs.he.calcSt1_o();

hs.cd.work();

hs.pu.p = hs.otb.st_i.p;    %% Assume no pressure drop
hs.pu.work();

hs.he.st1_o.T.v = hs.he.st2_i.T.v + DeltaT_1_2;
% hs.he.get_st2_o();
h_4_6 = hs.he.st1_i.h + hs.he.st2_i.h - hs.he.st1_o.h;
hs.he.st2_i.flowTo(hs.he.st2_o);
hs.he.st2_o.p = hs.he.st2_i.p;
hs.he.st2_o.T.v = CoolProp.PropsSI('T', 'H', h_4_6, 'P', ...
    hs.he.st2_o.p.v, hs.he.st2_o.fluid);

hs.ph.calcSt1_o();
hs.ev.calcSt1_o();

hs.ph.st2_o.T.v = hs.ph.st1_i.T.v + hs.DeltaT_1_4;
hs.sh.st2_i = hs.sec.st1_o;
hs.sh.st2_i.flowTo(hs.ph.st2_o);
hs.st1(2) = hs.sh.st2_i;
hs.ph.st2_o.p = hs.sh.st2_i.p;
hs.ph.st1_o.q_m.v = hs.ph.st2_o.q_m.v .* (hs.sh.st2_i.h - ...
    hs.ph.st2_o.h) ./ (hs.sh.st1_o.h - hs.ph.st1_i.h);

hs.ge.P = hs.otb.P .* hs.ge.eta;

hs.ev.st2_i.q_m = hs.sh.st2_i.q_m;
hs.ph.st2_i.q_m = hs.ev.st2_i.q_m;

hs.sh.get_imcprs_st2_o;

hs.ev.get_imcprs_st2_o;

% Calculate tca
% Assume it has the same performance of using oil as HTF
hs.tca.st_i.convergeTo(hs.tca.tc.st_i, 1);
hs.tca.st_o.convergeTo(hs.tca.tc.st_o, 1);
% hs.tca.tc.L_per_q_m;
hs.tca.calculate();
hs.tca.eta = hs.tca.tc.eta;

T1 = zeros(1,numel(hs.st1));
q_m1 = zeros(1,numel(hs.st1));
T2 = zeros(1,numel(hs.st2));
q_m2 = zeros(1,numel(hs.st2));
T4 = zeros(1,numel(hs.st4));
q_m4 = zeros(1,numel(hs.st4));
T1_i = zeros(1,hs.sec.n_se);
T1_o = zeros(1,hs.sec.n_se);
T2_i = zeros(1,hs.sec.n_se);
T2_o = zeros(1,hs.sec.n_se);

for i = 1 : numel(hs.st1)
    T1(i) = hs.st1(i).T.v;
    q_m1(i) = hs.st1(i).q_m.v;
end
for i = 1 : numel(hs.st2)
    T2(i) = hs.st2(i).T.v;
    q_m2(i) = hs.st2(i).q_m.v;
end
for i = 1 : numel(hs.st4)
    T4(i) = hs.st4(i).T.v;
    q_m4(i) = hs.st4(i).q_m.v;
end

for i = 1 : hs.sec.n_se
    T1_i(i) = hs.sec.se(i).st1_i.T.v;
    T1_o(i) = hs.sec.se(i).st1_o.T.v;
    T2_i(i) = hs.sec.se(i).st2_i.T.v;
    T2_o(i) = hs.sec.se(i).st2_o.T.v;
end

%% Rankine cycle efficiency and overall efficiency
Q_rankine = hs.sec.st1_i.q_m.v .* (hs.sec.st1_i.h -  hs.sec.st1_o.h) - hs.sec.P ...
    + hs.sh.st1_o.q_m.v .* (hs.sh.st1_o.h - hs.ph.st1_i.h) + ...
    hs.he.st2_o.q_m.v .* (hs.he.st2_o.h - hs.he.st2_i.h);
P_rankine = (hs.ge.P - hs.pu.P) ./ hs.ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_hs = hs.dca.st_o.q_m.v .* (hs.dca.st_o.h - hs.dca.st_i.h) ./ hs.dca.eta ...
    + hs.tca.st_o.q_m.v .* (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_hs = hs.ge.P + hs.sec.P - hs.pu.P;
eta_hs = P_hs ./ Q_hs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss = SeparateSystem;

for i = 1 : 8
    ss.st4(i).fluid = char(Const.Fluid(4));
    ss.st4(i).T = Temperature(convtemp(340, 'C', 'K'));
    ss.st4(i).p.v = 2.8842e6;
    ss.st4(i).q_m.v = 6;         %%%%%%% To be automatically calculated later
end

ss.st2(1).q_m.v = 7.4;          %%%%%%%%%%
for i = 1 : 7
    ss.st4(i+1).q_m = ss.st4(1).q_m;
end

for i = 1 : 4
    ss.st3(i).fluid = char(Const.Fluid(3));
    ss.st3(i).T.v = convtemp(380, 'C', 'K');    % Design parameter
    ss.st3(i).p.v = 2e6;
end

ss.otb.st_i = ss.st4(1);
ss.otb.st_o = ss.st4(2);
ss.he.st1_i = ss.st4(2);
ss.he.st1_o = ss.st4(3);
ss.he.st2_i = ss.st4(5);
ss.he.st2_o = ss.st4(6);
ss.cd.st_i = ss.st4(3);
ss.cd.st_o = ss.st4(4);
ss.pu1.st_i = ss.st4(4);
ss.pu1.st_o = ss.st4(5);
ss.ph.st1_i = ss.st4(6);
ss.ph.st1_o = ss.st4(7);
ss.ph.st2_i = ss.st3(3);
ss.ph.st2_o = ss.st3(4);
ss.ev.st1_i = ss.st4(7);
ss.ev.st1_o = ss.st4(8);
ss.ev.st2_i = ss.st3(2);
ss.ev.st2_o = ss.st3(3);
ss.sh.st1_i = ss.st4(8);
ss.sh.st1_o = ss.st4(1);
ss.sh.st2_i = ss.st3(1);
ss.sh.st2_o = ss.st3(2);

ss.dca.n = hs.dca.n;
ss.dca.dc.amb = hs.dca.dc.amb;
ss.dca.eta = hs.dca.eta;
ss.ge.eta = hs.ge.eta;
ss.DeltaT_3_4 = hs.DeltaT_1_4;

ss.otb.st_i.T.v = hs.otb.st_i.T.v;
ss.otb.st_i.p = hs.otb.st_i.p;
ss.otb.st_o.p = hs.otb.st_o.p;

q_se = hs.sec.se(1).P ./ hs.sec.se(1).eta;  % Heat absorbed by the first
    % Stirling engine in sec of cascade sysem
T_H = hs.dca.dc.airPipe.T.v - q_se ./ (hs.sec.se(1).U_1 .* ...
    hs.sec.se(1).A_1);
T_L = 310;  % Parameter of 4-95 MKII engine
T_R = Const.LogMean(T_H, T_L);
e = (T_R - T_L) ./ (T_H - T_L);
eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (ss.se.k -1) ./ log(ss.se.gamma));
P_ss_se = hs.sec.st1_i.q_m.v * ...
    (hs.sec.st1_i.h - hs.sec.st1_o.h) .* eta_ss_se;

% ss.st4(6).T.v = hs.st4(6).T.v;
% ss.st4(6).p = hs.st4(6).p;
% ss.st4(6).q_m.v = hs.st4(6).q_m.v .* (hs.st4(1).h - hs.st4(6).h) ...
%     ./ (ss.st4(1).h - ss.st4(6).h);

ss.st4(2).T.v = hs.st4(2).T.v;
ss.st4(3).p = ss.st4(2).p;
ss.st4(3).x = 1;
ss.st4(3).T.v = CoolProp.PropsSI('T', 'Q', ss.st4(3).x, ...
    'P', ss.st4(3).p.v, ss.st4(3).fluid);
ss.st4(4).p = ss.st4(3).p;
ss.st4(4).x = 0;
ss.st4(4).T.v = CoolProp.PropsSI('T', 'Q', ss.st4(4).x, ...
    'P', ss.st4(4).p.v, ss.st4(4).fluid);
ss.pu1.p = ss.otb.st_i.p;
ss.pu1.work();

h_s_4_6 = ss.st4(2).h + ss.st4(5).h - ss.st4(3).h;
ss.st4(6).p = ss.st4(5).p;
ss.st4(7).p = ss.st4(6).p;
ss.st4(8).p = ss.st4(7).p;
ss.st4(6).T.v = CoolProp.PropsSI('T', 'H', ...
    h_s_4_6, 'P', ss.st4(6).p.v, ss.st4(6).fluid);
ss.st4(7).x = 0;
ss.st4(8).x = 1;
ss.st4(7).T.v = CoolProp.PropsSI('T', 'Q', ...
    ss.st4(7).x, 'P', ss.st4(7).p.v, ss.st4(7).fluid);
ss.st4(8).T.v = CoolProp.PropsSI('T', 'Q', ...
    ss.st4(8).x, 'P', ss.st4(8).p.v, ss.st4(8).fluid);

ss.st4(6).q_m.v = hs.st4(6).q_m.v .* (hs.st4(1).h - hs.st4(6).h) ...
    ./ (ss.st4(1).h - ss.st4(6).h);

ss.ge.P = ss.otb.P .* ss.ge.eta;

ss.pu1.work();

Q_ss_rankine = ss.sh.st1_o.q_m.v .* (ss.sh.st1_o.h - ss.ph.st1_i.h);

P_ss_rankine = (ss.ge.P - ss.pu1.P) ./ ss.ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

Q_ss = ss.dca.dc.q_tot .* ss.dca.n + hs.tca.st_o.q_m.v .* ...
    (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_ss = ss.ge.P + P_ss_se - ss.pu1.P;
eta_ss = P_ss ./ Q_ss;
%% Comparison
eta_diff(k) = (eta_hs - eta_ss) ./ eta_ss;
eta_hs_r(k) = eta_hs;
eta_sea(k) = hs.sec.eta;
used(k) = (hs.sec.P ./ hs.sec.eta) ./ (hs.dca.n .* hs.dca.dc.q_tot);
end