clear;
cs = CascadeSystem;
cs.sea = SEA(10, 'Reverse');
%% Streams
for i = 1 : 3
    cs.st1(i).fluid = char(Const.Fluid(1));
    cs.st1(i).T = Temperature(convtemp(800, 'C', 'K'));
    cs.st1(i).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
%     cs.st1(i).q_m.v = 3.9;          %%%%%%% To be calculated!
end
%     cs.st1(1).q_m.v = 4;
for i = 1 : 2
    cs.st1(i+1).q_m = cs.st1(1).q_m;
end

for i = 1 : 11
    cs.st2(i).fluid = char(Const.Fluid(2));
    cs.st2(i).T = Temperature(convtemp(340, 'C', 'K'));
    cs.st2(i).p = 2.35e6;
%     cs.st2(i).q_m.v = 9;         %%%%%%% To be calculated!
end
    cs.st2(1).q_m.v = 7.35;
for i = 1 : 5
    cs.st2(i+6).q_m = cs.st2(1).q_m;
end
for i = 1 : 3
    cs.st2(i+3).q_m = cs.st2(3).q_m;
end

for i = 1 : 4
    cs.st3(i).fluid = char(Const.Fluid(3));
    cs.st3(i).T = Temperature(convtemp(350, 'C', 'K'));    % Design parameter
    cs.st3(i).p = 2e6;
    %     cs.st3(i).q_m = Q_m(60);            %%%%%%%% Only a guess value, will
    % be automatically corrected latter
end

cs.dca.st_i = cs.st1(3);
cs.dca.st_o = cs.st1(1);
cs.sea.st1_i = cs.st1(1);
cs.sea.st1_o = cs.st1(2);
cs.sea.st2_i = cs.st2(5);
cs.sea.st2_o = cs.st2(6);
cs.he.st1_i = cs.st1(2);
cs.he.st1_o = cs.st1(3);
cs.he.st2_i = cs.st2(11);
cs.he.st2_o = cs.st2(1);
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
cs.sh.st1_o = cs.st2(11);
cs.sh.st2_i = cs.st3(1);
cs.sh.st2_o = cs.st3(2);
cs.tca.st_i = cs.st3(4);
cs.tca.st_o = cs.st3(1);

% Design parameters
cs.dca.st_i.T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter
cs.tb.st_o_2.p = 1.5e4;
cs.da.p = 1e6;
cs.DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

cs.dca.dc.st_i = cs.dca.st_i.diverge(1);
cs.dca.dc.st_o = cs.dca.st_o.diverge(1);
cs.dca.dc.calculate;
cs.dca.n = cs.dca.st_i.q_m.v ./ cs.dca.dc.st_i.q_m.v;
cs.dca.st_o.q_m = cs.dca.st_i.q_m;
cs.dca.eta = cs.dca.dc.eta;

cs.ge.P = 4e6;
cs.ge.eta = 0.975;

cs.tb.st_o_1.p = cs.da.p;
cs.tb.work(cs.ge);

cs.cd.work;

cs.pu1.p = cs.da.p;
cs.pu1.work;

cs.da.st_i_2.p = cs.da.p;
cs.da.work(cs.tb);

guess = zeros(2,cs.sea.n1);

if (strcmp(cs.sea.order, 'Same'))
    for j = 1 : cs.sea.n1
        guess(j,1) = cs.sea.st1_i.T.v - 27 * j;
        guess(j,2) = cs.sea.st2_i.T.v + 4 * j;
    end
elseif (strcmp(cs.sea.order, 'Reverse'))
    for j = 1 : cs.sea.n1
        guess(j,1) = cs.sea.st1_i.T.v - 27 * j;
        guess(j,2) = cs.sea.st2_i.T.v + ...
            4 * (cs.sea.n1 + 1 - j);
    end
end
cs.sea.calculate(guess);



cs.pu2.p = cs.tb.st_i.p;
cs.pu2.work;

cs.he.work;

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

% guess1 = zeros(2 * cs.sea.n1 + 1);
% 
% for j = 1 : cs.sea.n1
%     guess1(j) = cs.sea.se(j).st1_o.T.v;
%     guess1(cs.sea.n1 + j) = cs.sea.se(j).st2_o.T.v;
% end
% guess1(2 * cs.sea.n1 + 1) = 3.9;
% 
% options = optimset('Algorithm','levenberg-marquardt','Display','iter');
% [x, fval] = fsolve(@(x)CalcSystem(x, cs), ...
%     guess1, options);

for i = 1 : 3
    T1(i) = cs.st1(i).T.v;
    q_m1(i) = cs.st1(i).q_m.v;
end
for i = 1 : 11
    T2(i) = cs.st2(i).T.v;
    q_m2(i) = cs.st2(i).q_m.v;
end
for i = 1 : 4
    T3(i) = cs.st3(i).T.v;
    q_m3(i) = cs.st3(i).q_m.v;
end