clear;
%% Get results matrix
number = 1;
% eta_diff = zeros(1,number);
eta_cs_r = zeros(1,number);
eta_sea = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1 : number
hs = HeatSystem;
hs.sec = SEC(6, 'Parallel');
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
hs.dca.dc.amb.I_r = 400;
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
% hs.ge.P = 50e3;     % Will be automatically corrected
hs.dca.dc.get_q_m();
hs.dca.work();

hs.sec.calculate();

hs.otb.work(hs.ge);

hs.he.calcSt1_o();

hs.cd.work();

hs.pu.p = hs.otb.st_i.p;    %% Assume no pressure drop
hs.pu.work();

hs.he.st1_o.T.v = hs.he.st2_i.T.v + hs.he.DeltaT;
% hs.he.get_st2_o();
h_4_6 = hs.he.st1_i.h + hs.he.st2_i.h - hs.he.st1_o.h;
hs.he.st2_i.flowTo(hs.he.st2_o);
hs.he.st2_o.p = hs.he.st2_i.p;
hs.he.st2_o.T.v = CoolProp.PropsSI('T', 'H', h_4_6, 'P', ...
    hs.he.st2_o.p, hs.he.st2_o.fluid);

hs.ph.calcSt1_o();
hs.ev.calcSt1_o();

hs.ph.st2_o.T.v = hs.ph.st1_i.T.v + hs.DeltaT_1_4;
hs.sh.st2_i.flowTo(hs.ph.st2_o);
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
Q_rankine = hs.sec.st2_i.q_m.v .* (hs.sec.st2_o.h -  hs.sec.st2_i.h) ...
    + hs.sh.st1_o.q_m.v .* (hs.sh.st1_o.h - hs.ph.st1_i.h) + ...
    hs.he.st2_o.q_m.v .* (hs.he.st2_o.h - hs.he.st2_i.h);
P_rankine = (hs.ge.P - hs.pu.P) ./ hs.ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_hs = hs.dca.st_o.q_m.v .* (hs.dca.st_o.h - hs.dca.st_i.h) ./ hs.dca.eta ...
    + hs.tca.st_o.q_m.v .* (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_hs = hs.ge.P + hs.sec.P - hs.pu.P;
eta_hs = P_hs ./ Q_hs;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Comparison system
cs = HeatSystem;
cs.sec = SEC(hs.sec.n_se, 'Parallel');
% Cooling water stream for each Stirling engine
cs.st2 = hs.st2;
%% Connection and State points
cs.sec.st1_i = cs.dca.st_o;
cs.tca.st_i = cs.sec.st1_o;
cs.sh.st2_i = cs.tca.st_o;
cs.ev.st2_i = cs.sh.st2_o;
cs.ph.st2_i = cs.ev.st2_o;
cs.dca.st_i = cs.ph.st2_o;
cs.sec.st2_i = cs.st2;      % Cooling water stream for each Stirling engine

cs.st1(1) = cs.sec.st1_i;
cs.st1(2) = cs.tca.st_i;
cs.st1(3) = cs.sh.st2_i;
cs.st1(4) = cs.ev.st2_i;
cs.st1(5) = cs.ph.st2_i;
cs.st1(6) = cs.dca.st_i;

cs.otb.st_i = cs.sh.st1_o;
cs.he.st1_i = cs.otb.st_o;
cs.cd.st_i = cs.he.st1_o;
cs.pu.st_i = cs.cd.st_o;
cs.he.st2_i = cs.pu.st_o;
cs.ph.st1_i = cs.he.st2_o;
cs.ev.st1_i = cs.ph.st1_o;
cs.sh.st1_i = cs.ev.st1_o;

cs.st4(1) = cs.otb.st_i;
cs.st4(2) = cs.he.st1_i;
cs.st4(3) = cs.cd.st_i;
cs.st4(4) = cs.pu.st_i;
cs.st4(5) = cs.he.st2_i;
cs.st4(6) = cs.ph.st1_i;
cs.st4(7) = cs.ev.st1_i;
cs.st4(8) = cs.sh.st1_i;
%% Design parameters
cs.dca.n = hs.dca.n;
cs.dca.dc.amb.I_r = hs.dca.dc.amb.I_r;
cs.dca.dc.st_i.fluid = hs.dca.dc.st_i.fluid;
cs.dca.dc.st_i.T.v = hs.ph.st2_o.T.v;   % the same parameters of SEP 
% between HeatSystem and ComparisonSystem
cs.dca.dc.st_i.p = hs.dca.dc.st_i.p;
cs.dca.dc.st_i.q_m.v= hs.dca.dc.st_i.q_m.v;

cs.tca.tc.amb.I_r = hs.tca.tc.amb.I_r;
cs.tca.st_i.fluid = hs.tca.st_i.fluid;

cs.otb.st_i.fluid = hs.otb.st_i.fluid;
cs.otb.st_i.T.v = hs.otb.st_i.T.v;
cs.otb.st_i.p = hs.otb.st_i.p;
cs.otb.st_o.p = hs.otb.st_o.p;

cs.ge.eta = hs.ge.eta;

cs.he.DeltaT = hs.he.DeltaT;
cs.DeltaT_1_4 = hs.DeltaT_1_4;          % Minimun temperature difference between air
%and water

cs.sh.st2_i.fluid = hs.sh.st2_i.fluid;
cs.sh.st2_i.q_m.v = hs.sh.st2_i.q_m.v;
cs.sh.st2_i.p = hs.sh.st2_i.p;
cs.sh.st2_i.x = hs.sh.st2_i.x;
cs.sh.st2_i.T = hs.sh.st2_i.T;

cs.ph.st2_o.fluid = hs.ph.st2_o.fluid;
cs.ph.st2_i.p = hs.ph.st2_i.p;
cs.ph.st2_i.x = hs.ph.st2_i.x;
cs.ph.st2_i.T = hs.ph.st2_i.T;
%% Work
cs.dca.dc.get_T_o();
cs.dca.work();

cs.sec.calculate();
% Calculate tca
% Assume it has the same performance of using oil as HTF
cs.tca.st_i.convergeTo(cs.tca.tc.st_i, 1);
cs.tca.st_o.convergeTo(cs.tca.tc.st_o, 1);
% hs.tca.tc.L_per_q_m;
cs.tca.calculate();
cs.tca.eta = cs.tca.tc.eta;

P_cs = hs.ge.P + cs.sec.P - hs.pu.P;
Q_cs = cs.dca.st_o.q_m.v .* (cs.dca.st_o.h - cs.dca.st_i.h) ./ cs.dca.eta ...
    + cs.tca.st_o.q_m.v .* (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
eta_cs = P_cs ./ Q_cs;
eta_diff = (eta_hs - eta_cs) ./ eta_cs;