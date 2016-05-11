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
cs.sea = SEA(3, 'Reverse');
cs.sea.st1_i = cs.dca.st_o;
cs.dca.st_i = cs.sea.st1_o;

cs.st1(1) = cs.sea.st1_i;
cs.st1(2) = cs.dca.st_i;

cs.sh.st2_i = cs.tca.st_o;
cs.ev.st2_i = cs.sh.st2_o;
cs.ph.st2_i = cs.ev.st2_o;
cs.tca.st_i = cs.ph.st2_o;

cs.st3(1) = cs.sh.st2_i;
cs.st3(2) = cs.ev.st2_i;
cs.st3(3) = cs.ph.st2_i;
cs.st3(4) = cs.tca.st_i;

cs.otb1.st_i = cs.sh.st1_o;
cs.osh.st2_i = cs.otb1.st_o;
cs.oev.st2_i = cs.osh.st2_o;
cs.oph.st2_i = cs.oev.st2_o;
cs.pu1.st_i = cs.oph.st2_o;
cs.ph.st1_i = cs.pu1.st_o;
cs.ev.st1_i = cs.ph.st1_o;
cs.sh.st1_i = cs.ev.st1_o;

cs.st4(1) = cs.otb1.st_i;
cs.st4(2) = cs.osh.st2_i;
cs.st4(3) = cs.oev.st2_i;
cs.st4(4) = cs.oph.st2_i;
cs.st4(5) = cs.pu1.st_i;
cs.st4(6) = cs.ph.st1_i;
cs.st4(7) = cs.ev.st1_i;
cs.st4(8) = cs.sh.st1_i;

cs.otb2.st_i = cs.osh.st1_o;
cs.he.st1_i = cs.otb2.st_o;
cs.cd.st_i = cs.he.st1_o;
cs.pu2.st_i = cs.cd.st_o;
cs.sea.st2_i = cs.pu2.st_o;
cs.he.st2_i = cs.sea.st2_o;
cs.oph.st1_i = cs.he.st2_o;
cs.oev.st1_i = cs.oph.st1_o;
cs.osh.st1_i = cs.oev.st1_o;

cs.st5(1) = cs.otb2.st_i;
cs.st5(2) = cs.he.st1_i;
cs.st5(3) = cs.cd.st_i;
cs.st5(4) = cs.pu2.st_i;
cs.st5(5) = cs.sea.st2_i;
cs.st5(6) = cs.he.st2_i;
cs.st5(7) = cs.oph.st1_i;
cs.st5(8) = cs.oev.st1_i;
cs.st5(9) = cs.osh.st1_i;


cs.dca.n = 1;
cs.sea.n_se = 3 * cs.dca.n;
cs.dca.dc.amb.I_r = 700;
cs.dca.dc.st_i.fluid = char(Const.Fluid(1));
cs.dca.dc.st_i.T.v = convtemp(500, 'C', 'K');   % Design parameter
cs.dca.dc.st_i.p = 5e5;
cs.dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

cs.tca.tc.amb.I_r = cs.dca.dc.amb.I_r;

cs.tca.st_o.fluid = char(Const.Fluid(3));
cs.tca.st_o.T.v = convtemp(380, 'C', 'K');
cs.tca.st_o.p = 2e6;

cs.otb1.fluid_d = char(Const.Fluid(4));
cs.otb1.T_s_d.v = convtemp(300, 'C', 'K');
cs.otb1.p_s_d = 2.8842e6;
cs.otb1.T_c_d.v = convtemp(228.85, 'C', 'K');
cs.otb1.p_c_d = 0.3605e6;
cs.otb1.st_i.fluid = cs.otb1.fluid_d;
cs.otb1.st_i.T.v = convtemp(300, 'C', 'K');
cs.otb1.st_i.p = 2.8842e6;
cs.otb1.st_o.p = 0.3605e6;

cs.otb2.fluid_d = char(Const.Fluid(5));
cs.otb2.T_s_d.v = convtemp(141.152, 'C', 'K');
cs.otb2.p_s_d = 1e6;
cs.otb2.T_c_d.v = convtemp(91.35, 'C', 'K');
cs.otb2.p_c_d = 0.167e6;
cs.otb2.st_i.fluid = cs.otb2.fluid_d;
cs.otb2.st_i.T.v = convtemp(141.152, 'C', 'K');
cs.otb2.st_i.p = 1e6;
cs.otb2.st_o.p = 0.167e6;

cs.oge1.eta = 0.975;
cs.oge2.P = 140e3;
cs.oge2.eta = 0.975;
cs.he.DeltaT = 15;
cs.DeltaT_3_4 = 15;          % Minimun temperature difference between oil
%and water

%% Work
cs.dca.dc.work();
cs.dca.work();

% cs.otb1.work(cs.oge1);
cs.otb2.work(cs.oge2);

cs.he.calcSt1_o();

cs.cd.work();

cs.pu2.p = cs.otb2.st_i.p;
cs.pu2.work();

%% Calculate the Stirling engine array
guess = zeros(2, cs.sea.n1+1);

if (strcmp(cs.sea.order, 'Same'))
    for j = 1 : cs.sea.n1
        guess(j,1) = cs.sea.st1_i.T.v - 27 * j;
        guess(j,2) = cs.sea.st2_i.T.v + 24 / 10 * j;
    end
elseif (strcmp(cs.sea.order, 'Reverse'))
    for j = 1 : cs.sea.n1
        guess(j,1) = cs.sea.st1_i.T.v - 27 * j;
        guess(j,2) = cs.sea.st2_i.T.v + ...
            24 / 10 * (cs.sea.n1 + 1 - j);
    end
end
% guess(cs.sea.n1+1, 1) = 5;
% guess(cs.sea.n1+1, 2) = cs.dca.st_i.q_m.v;

options = optimset('Algorithm','levenberg-marquardt','Display','iter');
[x] = fsolve(@(x)CalcSystem3(x, cs), guess, options);

cs.sea.st1_o.T = cs.sea.se(cs.sea.n1).st1_o.T;
cs.sea.st1_o.p = cs.sea.se(cs.sea.n1).st1_o.p;

P1 = zeros(cs.sea.n1,1);

for i = 1 : cs.sea.n1
    cs.sea.se(i).P = cs.sea.se(i).P1();
    cs.sea.se(i).eta = cs.sea.se(i).P ./ (cs.sea.se(i).st1_i.q_m.v .* ...
        (cs.sea.se(i).st1_i.h - cs.sea.se(i).st1_o.h));
    P1(i) = cs.sea.se(i).P2();
end
cs.sea.eta = sum(P1) ./ (cs.sea.st1_i_r.q_m.v * ...
    (cs.sea.se(1).st1_i.h - cs.sea.se(cs.sea.n1).st1_o.h));
cs.sea.st2_o.q_m = cs.sea.st2_i.q_m;
cs.sea.P = sum(P1) .* cs.sea.n2;
cs.sea.st1_o.q_m = cs.sea.st1_i.q_m;
cs.sea.st2_o.q_m = cs.sea.st2_i.q_m;

cs.he.st1_o.T.v = cs.he.st2_i.T.v + cs.he.DeltaT;

cs.he.get_st2_o();
cs.oph.calcSt1_o();
cs.oev.calcSt1_o();

cs.otb1.flowInTurbine(cs.otb1.st_i, cs.otb1.st_o, cs.otb1.st_o.p);
cs.st4(3).p = cs.st4(2).p;
cs.st4(4).p = cs.st4(3).p;
cs.st4(5).p = cs.st4(4).p;
cs.st4(5).fluid = cs.st4(2).fluid;
cs.st4(5).x = 0;
cs.st4(5).T.v = CoolProp.PropsSI('T', 'Q', ...
    cs.st4(5).x, 'P', cs.st4(5).p, cs.st4(5).fluid);

cs.st4(2).q_m.v = cs.st5(1).q_m.v .* (cs.st5(1).h - ...
    cs.st5(7).h) ./ (cs.st4(2).h - cs.st4(5).h);
cs.st4(1).q_m = cs.st4(2).q_m;

cs.osh.get_st2_o();
cs.oev.get_st2_o();
cs.oph.st2_o.q_m = cs.oph.st2_i.q_m;

cs.pu1.p = cs.st4(1).p;
cs.pu1.work();

% get q_m_3
cs.ph.calcSt1_o();
cs.ev.calcSt1_o();

cs.ph.st2_o.T.v = cs.ph.st1_i.T.v + cs.DeltaT_3_4;
cs.sh.st2_i.flowTo(cs.ph.st2_o);
cs.ph.st2_o.p = cs.sh.st2_i.p;
cs.ph.st2_o.q_m.v = cs.ph.st1_o.q_m.v .* (cs.sh.st1_o.h - ...
    cs.ph.st1_i.h) ./ (cs.sh.st2_i.h - cs.ph.st2_o.h);
cs.sh.st2_i.q_m = cs.ph.st2_o.q_m;

cs.sh.get_imcprs_st2_o;

cs.ev.get_imcprs_st2_o;

cs.oge1.P = cs.otb1.P .* cs.oge1.eta;

cs.tca.st_i.convergeTo(cs.tca.tc.st_i, 1);
cs.tca.st_o.convergeTo(cs.tca.tc.st_o, 1);
cs.tca.tc.calculate;
cs.tca.n1 = cs.tca.tc.n;
cs.tca.n2 = cs.tca.st_i.q_m.v ./ cs.tca.tc.st_i.q_m.v;
cs.tca.eta = cs.tca.tc.eta;

T1 = zeros(1,2);
q_m1 = zeros(1,2);
T3 = zeros(1,4);
q_m3 = zeros(1,4);
T4 = zeros(1,8);
q_m4 = zeros(1,8);
T5 = zeros(1,9);
q_m5 = zeros(1,9);
T1_i = zeros(1,cs.sea.n1);
T1_o = zeros(1,cs.sea.n1);
T2_i = zeros(1,cs.sea.n1);
T2_o = zeros(1,cs.sea.n1);

for i = 1 : 2
    T1(i) = cs.st1(i).T.v;
    q_m1(i) = cs.st1(i).q_m.v;
end
for i = 1 : 4
    T3(i) = cs.st3(i).T.v;
    q_m3(i) = cs.st3(i).q_m.v;
end
for i = 1 : 8
    T4(i) = cs.st4(i).T.v;
    q_m4(i) = cs.st4(i).q_m.v;
end
for i = 1 : 9
    T5(i) = cs.st5(i).T.v;
    q_m5(i) = cs.st5(i).q_m.v;
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
P_rankine = (cs.oge1.P + cs.oge2.P - cs.pu1.P - cs.pu2.P) ./ cs.oge1.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_cs = cs.dca.st_o.q_m.v .* (cs.dca.st_o.h - cs.dca.st_i.h) ./ cs.dca.eta ...
    + cs.tca.st_o.q_m.v .* (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
P_cs = cs.oge1.P + cs.oge2.P + cs.sea.P - cs.pu1.P - cs.pu2.P;
eta_cs = P_cs ./ Q_cs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss = SeparateSystem;

for i = 1 : 8
    ss.st4(i).fluid = char(Const.Fluid(4));
    ss.st4(i).T = Temperature(convtemp(340, 'C', 'K'));
    ss.st4(i).p = 2.8842e6;
    ss.st4(i).q_m.v = 6;         %%%%%%% To be automatically calculated later
end

ss.st2(1).q_m.v = 7.4;          %%%%%%%%%%
for i = 1 : 7
    ss.st4(i+1).q_m = ss.st4(1).q_m;
end

for i = 1 : 4
    ss.st3(i).fluid = char(Const.Fluid(3));
    ss.st3(i).T.v = convtemp(380, 'C', 'K');    % Design parameter
    ss.st3(i).p = 2e6;
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

ss.dca.n = cs.dca.n;
ss.dca.dc.amb = cs.dca.dc.amb;
ss.dca.eta = cs.dca.eta;
ss.ge.eta = cs.oge1.eta;
ss.DeltaT_3_4 = cs.DeltaT_3_4;

ss.otb.st_i.T.v = cs.otb1.st_i.T.v;
ss.otb.st_i.p = cs.otb1.st_i.p;
ss.otb.st_o.p = cs.otb1.st_o.p;

q_se = cs.sea.se(1).P ./ cs.sea.se(1).eta;  % Heat absorbed by the first
    % Stirling engine in SEA of cascade sysem
T_H = cs.dca.dc.airPipe.T.v - q_se ./ (cs.sea.se(1).U_1 .* ...
    cs.sea.se(1).A_1);
T_L = 310;  % Parameter of 4-95 MKII engine
T_R = Const.LogMean(T_H, T_L);
e = (T_R - T_L) ./ (T_H - T_L);
eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (ss.se.k -1) ./ log(ss.se.gamma));
ss.se.P = ss.dca.dc.q_tot .* ss.dca.eta .* ss.dca.n .* eta_ss_se;

% ss.st4(6).T.v = cs.st4(6).T.v;
% ss.st4(6).p = cs.st4(6).p;
% ss.st4(6).q_m.v = cs.st4(6).q_m.v .* (cs.st4(1).h - cs.st4(6).h) ...
%     ./ (ss.st4(1).h - ss.st4(6).h);

ss.st4(2).T.v = cs.st4(2).T.v;
ss.st4(3).p = ss.st4(2).p;
ss.st4(3).x = 1;
ss.st4(3).T.v = CoolProp.PropsSI('T', 'Q', ss.st4(3).x, ...
    'P', ss.st4(3).p, ss.st4(3).fluid);
ss.st4(4).p = ss.st4(3).p;
ss.st4(4).x = 0;
ss.st4(4).T.v = CoolProp.PropsSI('T', 'Q', ss.st4(4).x, ...
    'P', ss.st4(4).p, ss.st4(4).fluid);
ss.pu1.p = ss.otb.st_i.p;
ss.pu1.work();

h_s_4_6 = ss.st4(2).h + ss.st4(5).h - ss.st4(3).h;
ss.st4(6).p = ss.st4(5).p;
ss.st4(7).p = ss.st4(6).p;
ss.st4(8).p = ss.st4(7).p;
ss.st4(6).T.v = CoolProp.PropsSI('T', 'H', ...
    h_s_4_6, 'P', ss.st4(6).p, ss.st4(6).fluid);
ss.st4(7).x = 0;
ss.st4(8).x = 1;
ss.st4(7).T.v = CoolProp.PropsSI('T', 'Q', ...
    ss.st4(7).x, 'P', ss.st4(7).p, ss.st4(7).fluid);
ss.st4(8).T.v = CoolProp.PropsSI('T', 'Q', ...
    ss.st4(8).x, 'P', ss.st4(8).p, ss.st4(8).fluid);

ss.st4(6).q_m.v = cs.st4(6).q_m.v .* (cs.st4(1).h - cs.st4(6).h) ...
    ./ (ss.st4(1).h - ss.st4(6).h);

ss.ge.P = ss.otb.P .* ss.ge.eta;

ss.pu1.work();

Q_ss_rankine = ss.sh.st1_o.q_m.v .* (ss.sh.st1_o.h - ss.ph.st1_i.h);

P_ss_rankine = (ss.ge.P - ss.pu1.P) ./ ss.ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

Q_ss = ss.dca.dc.q_tot .* ss.dca.n + cs.tca.st_o.q_m.v .* ...
    (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
P_ss = ss.ge.P + ss.se.P - ss.pu1.P;
eta_ss = P_ss ./ Q_ss;
%% Comparison
eta_diff(k) = (eta_cs - eta_ss) ./ eta_ss;
eta_cs_r(k) = eta_cs;
eta_sea(k) = cs.sea.eta;
used(k) = (cs.sea.P ./ cs.sea.eta) ./ (cs.dca.n .* cs.dca.dc.q_tot);
end
