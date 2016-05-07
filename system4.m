clear;
%% Get results matrix
number = 1;
eta_diff = zeros(1,number);
eta_cs_r = zeros(1,number);
eta_sea = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1:number
hs = HeatSystem;
hs.dca.n = 3;
% hs.sea = SEA(3, 'Reverse');
% hs.sea.n_se = 3 * hs.dca.n;
hs.dca.dc.amb.I_r = 700;
hs.tca.tc.amb.I_r = hs.dca.dc.amb.I_r;
%% Streams
for i = 1 : 3
    hs.st1(i).fluid = char(Const.Fluid(1));
    hs.st1(i).T = Temperature(convtemp(800, 'C', 'K'));
    hs.st1(i).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
    hs.st1(i).q_m.v = 1;          %%%%%%% To be automatically calculated later
end
for i = 1 : 2
    hs.st1(i+1).q_m = hs.st1(1).q_m;
end
for i = 1 : 11
    hs.st2(i).fluid = char(Const.Fluid(2));
    hs.st2(i).T = Temperature(convtemp(340, 'C', 'K'));
    hs.st2(i).p = 2.35e6;
    hs.st2(i).q_m = Q_m(6);         %%%%%%% To be automatically calculated later
end
hs.st2(1).q_m.v = 7.21;          %%%%%%%%%%
for i = 1 : 4
    hs.st2(i+7).q_m = hs.st2(1).q_m;
end
for i = 1 : 3
    hs.st2(i+3).q_m = hs.st2(3).q_m;
end

for i = 1 : 4
    hs.st3(i).fluid = char(Const.Fluid(3));
    hs.st3(i).T = Temperature(convtemp(380, 'C', 'K'));    % Design parameter
    hs.st3(i).p = 2e6;
end

hs.dca.st_i = hs.st1(3);
hs.dca.st_o = hs.st1(1);
hs.sea.st1_i = hs.st1(1);
hs.sea.st1_o = hs.st1(2);
hs.sea.st2_i = hs.st2(5);
hs.sea.st2_o = hs.st2(6);
hs.he.st1_i = hs.st1(2);
hs.he.st1_o = hs.st1(3);
hs.he.st2_i = hs.st2(11);
hs.he.st2_o = hs.st2(1);
hs.tb.st_i = hs.st2(1);
hs.tb.st_o_1 = hs.st2(2);
hs.tb.st_o_2 = hs.st2(3);
hs.cd.st_i = hs.st2(3);
hs.cd.st_o = hs.st2(4);
hs.pu1.st_i = hs.st2(4);
hs.pu1.st_o = hs.st2(5);
hs.da.st_i_1 = hs.st2(2);
hs.da.st_i_2 = hs.st2(6);
hs.da.st_o = hs.st2(7);
hs.pu2.st_i = hs.st2(7);
hs.pu2.st_o = hs.st2(8);
hs.ph.st1_i = hs.st2(8);
hs.ph.st1_o = hs.st2(9);
hs.ph.st2_i = hs.st3(3);
hs.ph.st2_o = hs.st3(4);
hs.ev.st1_i = hs.st2(9);
hs.ev.st1_o = hs.st2(10);
hs.ev.st2_i = hs.st3(2);
hs.ev.st2_o = hs.st3(3);
hs.sh.st1_i = hs.st2(10);
hs.sh.st1_o = hs.st2(11);
hs.sh.st2_i = hs.st3(1);
hs.sh.st2_o = hs.st3(2);
hs.tca.st_i = hs.st3(4);
hs.tca.st_o = hs.st3(1);

% Design parameters
% cs.dca.n = 30;
hs.dca.st_i.T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter
% cs.dca.st_i.T = Temperature(convtemp(400, 'C', 'K'));   % Design parameter
hs.tb.st_o_2.p = 1.5e4;
hs.da.p = 1e6;
hs.DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

hs.dca.dc.st_i = hs.dca.st_i.diverge(1);
hs.dca.dc.st_o = hs.dca.st_o.diverge(1);
hs.dca.dc.calculate;
hs.dca.st_i.q_m.v = hs.dca.n .* hs.dca.dc.st_i.q_m.v;
hs.dca.eta = hs.dca.dc.eta;

hs.ge.P = 4e6;
hs.ge.eta = 0.975;

%% Work
hs.tb.st_o_1.p = hs.da.p;
hs.tb.work(hs.ge);

hs.cd.work();

hs.pu1.p = hs.da.p;
hs.pu1.work();

hs.da.st_i_2.p = hs.da.p;
% cs.da.work(cs.tb);

%% Calculate the system
guess = zeros(2, hs.sea.n1+1);

if (strcmp(hs.sea.order, 'Same'))
    for j = 1 : hs.sea.n1
        guess(j,1) = hs.sea.st1_i.T.v - 38 * j;
        guess(j,2) = hs.sea.st2_i.T.v + 24 / 10 * j;
    end
elseif (strcmp(hs.sea.order, 'Reverse'))
    for j = 1 : hs.sea.n1
        guess(j,1) = hs.sea.st1_i.T.v - 38 * j;
        guess(j,2) = hs.sea.st2_i.T.v + ...
            24 / 10 * (hs.sea.n1 + 1 - j);
    end
end
guess(hs.sea.n1+1, 1) = 7.3;

options = optimset('Algorithm','levenberg-marquardt','Display','iter');
[x] = fsolve(@(x)CalcSystem1(x, hs), guess, options);

hs.sea.st1_o.T = hs.sea.se(hs.sea.n1).st1_o.T;
hs.sea.st1_o.p = hs.sea.se(hs.sea.n1).st1_o.p;

P1 = zeros(hs.sea.n1,1);

for i = 1 : hs.sea.n1
    hs.sea.se(i).P = hs.sea.se(i).P1();
    hs.sea.se(i).eta = hs.sea.se(i).P ./ (hs.sea.se(i).st1_i.q_m.v .* ...
        (hs.sea.se(i).st1_i.h - hs.sea.se(i).st1_o.h));
    P1(i) = hs.sea.se(i).P2();
end
hs.sea.eta = sum(P1) ./ (hs.sea.st1_i_r.q_m.v * ...
    (hs.sea.se(1).st1_i.h - hs.sea.se(hs.sea.n1).st1_o.h));
hs.sea.st2_o.q_m = hs.sea.st2_i.q_m;
hs.sea.P = sum(P1) .* hs.sea.n2;
hs.sea.st1_o.q_m = hs.sea.st1_i.q_m;
hs.sea.st2_o.q_m = hs.sea.st2_i.q_m;

hs.pu2.p = hs.tb.st_i.p;
hs.pu2.work;

hs.he.work;

% get q_m_3
hs.ph.st1_o.x = 0;
hs.ph.st1_o.T.v = CoolProp.PropsSI('T', 'P', hs.ph.st1_o.p, ...
    'Q', hs.ph.st1_o.x, hs.ph.st1_o.fluid);
hs.ph.st2_i.T.v = hs.ph.st1_o.T.v + hs.DeltaT_3_2;
hs.ph.st2_i.q_m.v = hs.ph.st1_o.q_m.v .* (hs.sh.st1_o.h - ...
    hs.ph.st1_o.h) ./ (hs.sh.st2_i.h - hs.ph.st2_i.h);

hs.ph.calculate;

hs.ev.calculate;

hs.sh.calculate;

hs.tca.tc.st_i = hs.tca.st_i.diverge(1);
hs.tca.tc.st_o = hs.tca.st_o.diverge(1);
hs.tca.tc.calculate;
hs.tca.n1 = hs.tca.tc.n;
hs.tca.n2 = hs.tca.st_i.q_m.v ./ hs.tca.tc.st_i.q_m.v;
hs.tca.eta = hs.tca.tc.eta;

T1 = zeros(1,3);
q_m1 = zeros(1,3);
T2 = zeros(1,11);
q_m2 = zeros(1,11);
T3 = zeros(1,11);
q_m3 = zeros(1,3);
T1_i = zeros(1,hs.sea.n1);
T1_o = zeros(1,hs.sea.n1);
T2_i = zeros(1,hs.sea.n1);
T2_o = zeros(1,hs.sea.n1);

for i = 1 : 3
    T1(i) = hs.st1(i).T.v;
    q_m1(i) = hs.st1(i).q_m.v;
end
for i = 1 : 11
    T2(i) = hs.st2(i).T.v;
    q_m2(i) = hs.st2(i).q_m.v;
end
for i = 1 : 4
    T3(i) = hs.st3(i).T.v;
    q_m3(i) = hs.st3(i).q_m.v;
end

for i = 1 : hs.sea.n1
    T1_i(i) = hs.sea.se(i).st1_i.T.v;
    T1_o(i) = hs.sea.se(i).st1_o.T.v;
    T2_i(i) = hs.sea.se(i).st2_i.T.v;
    T2_o(i) = hs.sea.se(i).st2_o.T.v;
end

%% Rankine cycle efficiency and overall efficiency
Q_rankine = hs.sea.st2_i.q_m.v .* (hs.sea.st2_o.h -  hs.sea.st2_i.h) ...
    + hs.sh.st1_o.q_m.v .* (hs.sh.st1_o.h - hs.ph.st1_i.h) + ...
    hs.he.st2_o.q_m.v .* (hs.he.st2_o.h - hs.he.st2_i.h);
P_rankine = (hs.ge.P - hs.pu1.P - hs.pu2.P) ./ hs.ge.eta;
eta_rankine = P_rankine ./ Q_rankine;

Q_cs = hs.dca.st_o.q_m.v .* (hs.dca.st_o.h - hs.dca.st_i.h) ./ hs.dca.eta ...
    + hs.tca.st_o.q_m.v .* (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_cs = hs.ge.P + hs.sea.P - hs.pu1.P - hs.pu2.P;
eta_cs = P_cs ./ Q_cs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss = SeparateSystem;

for i = 1 : 9
    ss.st2(i).fluid = char(Const.Fluid(2));
    ss.st2(i).T = Temperature(convtemp(340, 'C', 'K'));
    ss.st2(i).p = 2.35e6;
    ss.st2(i).q_m = Q_m(6);         %%%%%%% To be automatically calculated later
end

ss.st2(1).q_m.v = 7.4;          %%%%%%%%%%
for i = 1 : 4
    ss.st2(i+5).q_m = ss.st2(1).q_m;
end

for i = 1 : 2
    ss.st2(i+3).q_m = ss.st2(3).q_m;
end

for i = 1 : 4
    ss.st3(i).fluid = char(Const.Fluid(3));
    ss.st3(i).T = Temperature(convtemp(380, 'C', 'K'));    % Design parameter
    ss.st3(i).p = 2e6;
end

ss.tb.st_i = ss.st2(1);
ss.tb.st_o_1 = ss.st2(2);
ss.tb.st_o_2 = ss.st2(3);
ss.cd.st_i = ss.st2(3);
ss.cd.st_o = ss.st2(4);
ss.pu1.st_i = ss.st2(4);
ss.pu1.st_o = ss.st2(5);
ss.da.st_i_1 = ss.st2(2);
ss.da.st_i_2 = ss.st2(5);
ss.da.st_o = ss.st2(6);
ss.pu2.st_i = ss.st2(6);
ss.pu2.st_o = ss.st2(7);
ss.ph.st1_i = ss.st2(7);
ss.ph.st1_o = ss.st2(8);
ss.ph.st2_i = ss.st3(3);
ss.ph.st2_o = ss.st3(4);
ss.ev.st1_i = ss.st2(8);
ss.ev.st1_o = ss.st2(9);
ss.ev.st2_i = ss.st3(2);
ss.ev.st2_o = ss.st3(3);
ss.sh.st1_i = ss.st2(9);
ss.sh.st1_o = ss.st2(1);
ss.sh.st2_i = ss.st3(1);
ss.sh.st2_o = ss.st3(2);

ss.dca.n = hs.dca.n;
ss.dca.dc.amb = hs.dca.dc.amb;
ss.dca.eta = hs.dca.eta;
ss.ge.eta = hs.ge.eta;
ss.tb.st_o_2.p = hs.tb.st_o_2.p;
ss.da.p = hs.da.p;
ss.DeltaT_3_2 = hs.DeltaT_3_2;

q_se = hs.sea.se(1).P ./ hs.sea.se(1).eta;  % Heat absorbed by the first
    % Stirling engine in SEA of cascade sysem
T_H = hs.dca.dc.airPipe.T.v - q_se ./ (hs.sea.se(1).U_1 .* ...
    hs.sea.se(1).A_1);
T_L = 310;  % Parameter of 4-95 MKII engine
T_R = Const.LogMean(T_H, T_L);
e = (T_R - T_L) ./ (T_H - T_L);
eta_ss_se = (T_H - T_L) ./ (T_H + (1 - e) .* (T_H - T_L) ...
                ./ (ss.se.k -1) ./ log(ss.se.gamma));
ss.se.P = ss.dca.dc.q_tot .* ss.dca.eta .* ss.dca.n .* eta_ss_se;

ss.st2(7).T.v = hs.st2(8).T.v;
ss.st2(7).q_m.v = hs.st2(8).q_m.v .* (hs.st2(11).h - hs.st2(8).h) ...
    ./ (ss.st2(1).h - ss.st2(7).h);     %% Why?

ss.st2(2).T.v = hs.st2(2).T.v;
ss.st2(3).T.v = hs.st2(3).T.v;
ss.st2(5).T.v = hs.st2(5).T.v;
ss.st2(6).T.v = hs.st2(6).T.v;
ss.st2(3).x = hs.st2(3).x;
ss.st2(6).x = 0;
ss.st2(2).p = ss.da.p;
ss.st2(5).p = ss.da.p;
ss.st2(6).p = ss.da.p;
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

Q_ss_rankine = ss.sh.st1_o.q_m.v .* (ss.sh.st1_o.h - ss.ph.st1_i.h);

P_ss_rankine = (ss.ge.P - ss.pu1.P - hs.pu2.P) ./ ss.ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

Q_ss = ss.dca.dc.q_tot .* ss.dca.n + hs.tca.st_o.q_m.v .* ...
    (hs.tca.st_o.h - hs.tca.st_i.h) ./ hs.tca.eta;
P_ss = ss.ge.P + ss.se.P - ss.pu1.P - ss.pu2.P;
eta_ss = P_ss ./ Q_ss;
%% Comparison
eta_diff(k) = (eta_cs - eta_ss) ./ eta_ss;
eta_cs_r(k) = eta_cs;
eta_sea(k) = hs.sea.eta;
ratio(k) = hs.sea.P ./ hs.ge.P;
used(k) = (hs.sea.P ./ hs.sea.eta) ./ (hs.dca.n .* hs.dca.dc.q_tot);
end