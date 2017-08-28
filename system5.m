clear;
% This is the system for patent application
%% Get results matrix
number = 1;
cs = CascadeSystem5.empty;
ss = SeparateSystem5.empty;
eta_diff = zeros(1,number);
ratio = zeros(1,number);
P1 = zeros(1,number);
P2 = zeros(1, number);
DeltaA = zeros(1, number);

for k = 1:number
cs(k) = CascadeSystem5;
ss(k) = SeparateSystem5;
%% Connection and State points
cs(k).initialize();
cs(k).sea.n1 = 1;
cs(k).sea.n2 = k;
% cs(k).sea.st1_i = cs(k).dca.st_o;
% cs(k).dca.st_i = cs(k).sea.st1_o;

% cs(k).st1(1) = cs(k).sea.st1_i;
% cs(k).st1(2) = cs(k).dca.st_i;

%% Design parameters
% cs(k).dca.n = k;
% 
% cs(k).dca.dc.amb.I_r = 700;
% cs(k).dca.dc.st_i.fluid = char(Const.Fluid(1));
% cs(k).dca.dc.st_i.T.v = convtemp(350, 'C', 'K');   % Design parameter
% cs(k).dca.dc.st_i.p.v = 5e5;
% cs(k).dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

cs(k).tca.tc.amb.I_r = 700;

cs(k).tca.st_o.fluid = char(Const.Fluid(3));
cs(k).tca.st_o.T.v = convtemp(380, 'C', 'K');
cs(k).tca.st_o.p.v = 2e6;

cs(k).tb.st_i.fluid = char(Const.Fluid(2));
cs(k).tb.st_i.T.v = convtemp(340, 'C', 'K');
cs(k).tb.st_i.p.v = 2.35e6;
cs(k).tb.st_o_2.p.v = 1.5e4;

cs(k).ge.P = 2e5;
cs(k).ge.eta = 0.975;

cs(k).da.p.v = 1e6;

cs(k).DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

%% Work
% cs(k).dca.dc.get_q_m();
% cs(k).dca.work();

cs(k).calculate();
T2 = zeros(1,numel(cs(k).st2));
q_m2 = zeros(1,numel(cs(k).st2));
T3 = zeros(1,numel(cs(k).st3));
q_m3 = zeros(1,numel(cs(k).st3));
T2_i = zeros(1,cs(k).sea.n1);
T2_o = zeros(1,cs(k).sea.n1);

for i = 1 : numel(cs(k).st2)
    T2(i) = cs(k).st2(i).T.v;
    q_m2(i) = cs(k).st2(i).q_m.v;
end
for i = 1 : numel(cs(k).st3)
    T3(i) = cs(k).st3(i).T.v;
    q_m3(i) = cs(k).st3(i).q_m.v;
end

for i = 1 : cs(k).sea.n1
    T2_i(i) = cs(k).sea.se(i).st2_i.T.v;
    T2_o(i) = cs(k).sea.se(i).st2_o.T.v;
end

%% Rankine cycle efficiency and overall efficiency


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss(k).initialize();
for i = 1 : 9
    ss(k).st2(i).fluid = char(Const.Fluid(2));
end

%% Design parameters
ss(k).dca.eta = cs(k).dca.eta;
ss(k).ge.eta = cs(k).ge.eta;
ss(k).tb.st_i.T = cs(k).tb.st_i.T;
ss(k).tb.st_i.p = cs(k).tb.st_i.p;
ss(k).tb.st_o_2.p = cs(k).tb.st_o_2.p;
ss(k).da.p = cs(k).da.p;
ss(k).DeltaT_3_2 = cs(k).DeltaT_3_2;

% q_se = cs(k).sea.se(1).P ./ cs(k).sea.se(1).eta;  % Heat absorbed by the first
%     % Stirling engine in SEA of cascade sysem
st_cool = Stream;
st_cool.fluid = char(Const.Fluid(2));
st_cool.q_m.v = 0.3 * k;
st_cool.T.v = 303.15;
st_cool.p.v = 1e5;

ss(k).se = SEF;
ss(k).se.n1 = cs(k).sea.n1;
ss(k).se.n2 = cs(k).sea.n2;
ss(k).se.st2_i = st_cool;
ss(k).se.calculate();

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
ss(k).da.get_p();
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

Q_ss_rankine = ss(k).sh.st1_o.q_m.v .* (ss(k).sh.st1_o.h - ss(k).ph.st1_i.h);

P_ss_rankine = (ss(k).ge.P - ss(k).pu1.P - cs(k).pu2.P) ./ ss(k).ge.eta;
eta_ss_rankine = P_ss_rankine ./ Q_ss_rankine;

ss(k).Q = ss(k).se.P ./ ss(k).se.eta ./ ss(k).dca.eta + cs(k).tca.st_o.q_m.v .* ...
    (cs(k).tca.st_o.h - cs(k).tca.st_i.h) ./ cs(k).tca.eta;
ss(k).P = ss(k).ge.P + ss(k).se.P - ss(k).pu1.P - ss(k).pu2.P;
ss(k).eta = ss(k).P ./ ss(k).Q;
%% Comparison
eta_diff(k) = (cs(k).eta - ss(k).eta) ./ ss(k).eta;
ratio(k) = cs(k).sea.P ./ cs(k).ge.P;
P1(k) = cs(k).sea.P;
P2(k) = ss(k).se.P;
DeltaA(k) = (cs(k).sea.P ./ cs(k).sea.eta ./ cs(k).dca.eta - ss(k).se.P ./ ss(k).se.eta ...
    ./ss(k).dca.eta) ./ cs(k).tca.tc.amb.I_r;
end