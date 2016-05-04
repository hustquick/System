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
cs.dca.n = 30;
cs.sea = SEA(10, 'Reverse');
cs.sea.n_se = 3 * cs.dca.n;
cs.dca.dc.amb.I_r = 700;
cs.tca.tc.amb.I_r = cs.dca.dc.amb.I_r;
%% Streams
for i = 1 : 2
    cs.st1(i).fluid = char(Const.Fluid(1));
    cs.st1(i).T = Temperature(convtemp(800, 'C', 'K')); %%UNKOWN HERE
    cs.st1(i).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
    cs.st1(i).q_m.v = 1;          %%%%%%% To be automatically calculated later
end
cs.st1(2).q_m = cs.st1(1).q_m;
for i = 1 : 10
    cs.st2(i).fluid = char(Const.Fluid(2));
    cs.st2(i).T = Temperature(convtemp(340, 'C', 'K'));
    cs.st2(i).p = 2.35e6;
    cs.st2(i).q_m = Q_m(6);         %%%%%%% To be automatically calculated later
end
cs.st2(1).q_m.v = 7;
for i = 1 : 4
    cs.st2(i+6).q_m = cs.st2(1).q_m;
end
for i = 1 : 3
    cs.st2(i+3).q_m = cs.st2(3).q_m;
end
for i = 1 : 4
    cs.st3(i).fluid = char(Const.Fluid(3));
    cs.st3(i).T = Temperature(convtemp(380, 'C', 'K'));    % Design parameter
    cs.st3(i).p = 2e6;
end

cs.dca.st_i = cs.st1(2);
cs.dca.st_o = cs.st1(1);
cs.sea.st1_i = cs.st1(1);
cs.sea.st1_o = cs.st1(2);
cs.sea.st2_i = cs.st2(5);
cs.sea.st2_o = cs.st2(6);
cs.tb.st_i = cs.st2(1);
cs.tb.st_o_1 = cs.st2(2);
cs.tb.st_o_2 = cs.st2(3);
cs.cd.st_i = cs.st2(3);
cs.cd.st_o = cs.st2(4);
cs.pu1.st_i = cs.st2(4);
cs.pu1.st_o = cs.st2(5);
cs.da.st_i_1 = cs.st2(2);
cs.da.st_i_2 = cs.st2(6);
cs.da.st_o = cs.st2(7);
cs.pu2.st_i = cs.st2(7);
cs.pu2.st_o = cs.st2(8);
cs.ph.st1_i = cs.st2(8);
cs.ph.st1_o = cs.st2(9);
cs.ph.st2_i = cs.st3(3);
cs.ph.st2_o = cs.st3(4);
cs.ev.st1_i = cs.st2(9);
cs.ev.st1_o = cs.st2(10);
cs.ev.st2_i = cs.st3(2);
cs.ev.st2_o = cs.st3(3);
cs.sh.st1_i = cs.st2(10);
cs.sh.st1_o = cs.st2(1);
cs.sh.st2_i = cs.st3(1);
cs.sh.st2_o = cs.st3(2);
cs.tca.st_i = cs.st3(4);
cs.tca.st_o = cs.st3(1);

% Design parameters
% cs.dca.n = 30;
cs.dca.st_i.T = Temperature(convtemp(500, 'C', 'K'));   %%%%%% To be automatically calculated
cs.tb.st_o_2.p = 1.5e4;
cs.da.p = 1e6;
cs.DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

cs.dca.dc.st_i = cs.dca.st_i.diverge(1);
cs.dca.dc.st_o = cs.dca.st_o.diverge(1);
cs.dca.dc.calculate;
cs.dca.st_i.q_m.v = cs.dca.n .* cs.dca.dc.st_i.q_m.v;
cs.dca.eta = cs.dca.dc.eta;

cs.ge.P = 4e6;
cs.ge.eta = 0.975;

%% Work
cs.tb.st_o_1.p = cs.da.p;
cs.tb.work(cs.ge);

cs.cd.work();

cs.pu1.p = cs.da.p;
cs.pu1.work();

cs.da.st_i_2.p = cs.da.p;

%% Calculate the system
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
guess(cs.sea.n1+1, 1) = 7.3;
% guess(cs.sea.n1+1, 2) = cs.dca.st_i.q_m.v;
guess(cs.sea.n1+1, 2) = 4;

options = optimset('Algorithm','levenberg-marquardt','Display','iter');
[x] = fsolve(@(x)CalcSystem2(x, cs), guess, options);

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

cs.pu2.p = cs.tb.st_i.p;
cs.pu2.work;

% get q_m_3
cs.ph.st1_o.x = 0;
cs.ph.st1_o.T.v = CoolProp.PropsSI('T', 'P', cs.ph.st1_o.p, ...
    'Q', cs.ph.st1_o.x, cs.ph.st1_o.fluid);
cs.ph.st2_i.T.v = cs.ph.st1_o.T.v + cs.DeltaT_3_2;
cs.ph.st2_i.q_m.v = cs.ph.st1_o.q_m.v .* (cs.sh.st1_o.h - ...
    cs.ph.st1_o.h) ./ (cs.sh.st2_i.h - cs.ph.st2_i.h);

cs.ph.calculate;

cs.ev.calculate;

cs.sh.calculate;

cs.tca.tc.st_i = cs.tca.st_i.diverge(1);
cs.tca.tc.st_o = cs.tca.st_o.diverge(1);
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

for i = 1 : 2
    T1(i) = cs.st1(i).T.v;
    q_m1(i) = cs.st1(i).q_m.v;
end
for i = 1 : 10
    T2(i) = cs.st2(i).T.v;
    q_m2(i) = cs.st2(i).q_m.v;
end
for i = 1 : 4
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
Q_rankine = cs.sea.st2_i.q_m.v .* (cs.sea.st2_i.h -  cs.sea.st2_o.h) ...
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

ss.dca.n = cs.dca.n;
ss.dca.dc.amb = cs.dca.dc.amb;
ss.dca.eta = cs.dca.eta;
ss.ge.eta = cs.ge.eta;
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
ss.se.P = ss.dca.dc.q_tot .* ss.dca.eta .* ss.dca.n .* eta_ss_se;

ss.st2(7).T.v = cs.st2(8).T.v;
ss.st2(7).q_m.v = cs.st2(8).q_m.v .* (cs.st2(1).h - cs.st2(8).h) ...
    ./ (ss.st2(1).h - ss.st2(7).h);

ss.st2(2).T.v = cs.st2(2).T.v;
ss.st2(3).T.v = cs.st2(3).T.v;
ss.st2(5).T.v = cs.st2(5).T.v;
ss.st2(6).T.v = cs.st2(6).T.v;
ss.st2(3).x = cs.st2(3).x;
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

P_ss_rankine = (ss.ge.P - ss.pu1.P - cs.pu2.P) ./ ss.ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

Q_ss = ss.dca.dc.q_tot .* ss.dca.n + cs.tca.st_o.q_m.v .* ...
    (cs.tca.st_o.h - cs.tca.st_i.h) ./ cs.tca.eta;
P_ss = ss.ge.P + ss.se.P - ss.pu1.P - ss.pu2.P;
eta_ss = P_ss ./ Q_ss;
%% Comparison
eta_diff(k) = (eta_cs - eta_ss) ./ eta_ss;
eta_cs_r(k) = eta_cs;
eta_sea(k) = cs.sea.eta;
ratio(k) = cs.sea.P ./ cs.ge.P;
used(k) = (cs.sea.P ./ cs.sea.eta) ./ (cs.dca.n .* cs.dca.dc.q_tot);
end