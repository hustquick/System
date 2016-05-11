clear;
%% Get results matrix
hs = HeatSystem;
hs.sec = SEC(3, 'Parallel');
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
hs.dca.n = 2;
hs.dca.dc.amb.I_r = 700;
hs.dca.dc.st_i.fluid = char(Const.Fluid(1));
hs.dca.dc.st_i.T.v = convtemp(350, 'C', 'K');
hs.dca.dc.st_i.p = 5e5;
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
hs.otb.st_i.p = 2.8842e6;
hs.otb.st_o.p = 0.3605e6;

% hs.otb.fluid_d = char(Const.Fluid(5));
% hs.otb.T_s_d.v = convtemp(141.152, 'C', 'K');
% hs.otb.p_s_d = 1e6;
% hs.otb.T_c_d.v = convtemp(91.35, 'C', 'K');
% hs.otb.p_c_d = 0.167e6;
% hs.otb.st_i.fluid = hs.otb.fluid_d;
% hs.otb.st_i.T.v = convtemp(141.152, 'C', 'K');
% hs.otb.st_i.p = 1e6;
% hs.otb.st_o.p = 0.167e6;

hs.ge.P = 500e3;
hs.ge.eta = 0.975;

hs.he.DeltaT = 15;
hs.DeltaT_1_4 = 15;          % Minimun temperature difference between air
%and water

% Cooling water stream for each Stirling engine
hs.st2.fluid = char(Const.Fluid(2));
hs.st2.T.v = 293.15;
hs.st2.p = 1.01325e5;
hs.st2.q_m.v = 0.67;
%% Work
hs.dca.dc.work();
hs.dca.work();

hs.sec.calculate();

hs.otb.work(hs.ge);

hs.he.calcSt1_o();

hs.cd.work();

hs.pu.p = hs.otb.st_i.p;    %% Assume no pressure drop
hs.pu.work();

hs.he.st1_o.T.v = hs.he.st2_i.T.v + hs.he.DeltaT;
hs.he.get_st2_o();

hs.ph.calcSt1_o();
hs.ev.calcSt1_o();

hs.ph.st2_o.T.v = hs.ph.st1_i.T.v + hs.DeltaT_1_4;
hs.sh.st2_i.flowTo(hs.ph.st2_o);
hs.ph.st2_o.p = hs.sh.st2_i.p;
hs.ph.st2_o.q_m.v = hs.ph.st1_o.q_m.v .* (hs.sh.st1_o.h - ...
    hs.ph.st1_i.h) ./ (hs.sh.st2_i.h - hs.ph.st2_o.h);
hs.sh.st2_i.q_m = hs.ph.st2_o.q_m;

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
Q_rankine = hs.sec.st2_i.q_m.v .* (hs.sec.st2_o.h -  hs.sec.st2_i.h) ...
    + hs.sh.st1_o.q_m.v .* (hs.sh.st1_o.h - hs.ph.st1_i.h) + ...
    hs.he.st2_o.q_m.v .* (hs.he.st2_o.h - hs.he.st2_i.h);
P_rankine = (hs.ge.P - hs.pu.P) ./ hs.ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_cs = hs.dca.st_o.q_m.v .* (hs.dca.st_o.h - hs.dca.st_i.h) ./ hs.dca.eta ...
    + hs.tca.st_o.q_m.v .* (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_cs = hs.ge.P + hs.sec.P - hs.pu.P;
eta_cs = P_cs ./ Q_cs;