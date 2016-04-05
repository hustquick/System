cs = CascadeSystem;
%% Streams
cs.st1(1).fluid = char(Const.Fluid(1));
cs.st1(1).T = Temperature(convtemp(800, 'C', 'K'));
cs.st1(1).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
cs.st1(1).q_m = Q_m(2.990);          %%%%%%% To be calculated!
cs.st1(2) = cs.st1(1).flow();
cs.st1(3) = cs.st1(2).flow();
cs.st1(3).T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter

cs.st2(1).fluid = char(Const.Fluid(2));
cs.st2(1).T = Temperature(convtemp(340, 'C', 'K'));
cs.st2(1).p = 2.35e6;
cs.st2(1).q_m = Q_m(6.672);         %%%%%%% To be calculated!
cs.st2(2).p = 1.5e4;
cs.st2(2).q_m = Q_m(5.625);         %%%%%%% To be calculated!
cs.st2(3).p = 1e6;
% cs.st2(4) = cs.st2(2).flow();
% cs.st2(5) = cs.st2(4).flow();
% cs.st2(6) = cs.st2(5).flow();
% cs.st2(8) = cs.st2(7).flow();
% cs.st2(9) = cs.st2(8).flow();
% cs.st2(10) = cs.st2(2).flow();

cs.st3(1).fluid = char(Const.Fluid(3));
cs.st3(1).T = Temperature(convtemp(350, 'C', 'K'));    % Design parameter
cs.st3(1).p = 2e6;
%% Dish collector array
cs.dca.st_i = cs.st1(3);
cs.dca.st_o = cs.st1(1);
cs.dca.dc.st_i.fluid = cs.st1(3).fluid;
cs.dca.dc.st_i.T = cs.st1(3).T;
cs.dca.dc.st_o.fluid = cs.st1(1).fluid;
cs.dca.dc.st_o.T = cs.st1(1).T;
cs.dca.dc.st_o.p = cs.st1(1).p;
cs.dca.dc.st_i.p = cs.dca.dc.st_o.p;
cs.st1(3).p = cs.dca.dc.st_i.p;
cs.dca.dc.calculate;
cs.dca.eta = cs.dca.dc.eta; 
cs.dca.n = cs.st1(1).q_m.v ./ cs.dca.dc.st_i.q_m.v;
%% Generator
cs.ge.P = 4e6;
cs.ge.eta = 0.975;
%% Turbine
% cs.tb.P = cs.ge.P * cs.ge.eta;
cs.tb.st_i = cs.st2(1);
cs.tb.st_o_1 = cs.st2(2);
cs.tb.st_o_2 = cs.st2(3);
cs.tb.flow;
cs.st2(2) = cs.tb.st_o_1;    % Necessary for the stream has been diverged in the turbine
cs.st2(3) = cs.tb.st_o_2;    % Necessary for the stream has been diverged in the turbine
%% Condenser
cs.cd.st1 = cs.st2(2);
cs.st2(4) = cs.cd.st2;
%% Pump 1
cs.pu1.p = cs.st2(3).p;
cs.pu1.st_i = cs.st2(4);
cs.st2(5) = cs.pu1.st_o;
%% Stirling engine array
n1 = 10;
cs.sea = SEA(n1, 'Reverse');
cs.sea.st1_i = cs.st1(1);
cs.sea.st1_o = cs.st1(2);
cs.sea.st2_i = cs.st2(5);
cs.sea.st2_o = cs.st2(6);
cs.sea.st1_o.fluid = cs.sea.st1_i.fluid;
cs.sea.st1_o.q_m = cs.sea.st1_i.q_m;
cs.sea.st1_o.p = cs.sea.st1_i.p;
cs.sea.st2_o.fluid = cs.sea.st2_i.fluid;
cs.sea.st2_o.q_m = cs.sea.st2_i.q_m;
cs.sea.st2_o.p = cs.sea.st2_i.p;
cs.sea.calculate();
%% Deaerator
cs.da.p = cs.st2(3).p;
cs.da.st_i_1 = cs.st2(3);
cs.da.st_i_2 = cs.st2(6);
cs.st2(7) = cs.da.st_o;
%% Pump 2
cs.pu2.p = cs.st2(1).p;
cs.pu2.st_i = cs.st2(7);
cs.st2(8) = cs.pu2.st_o;
%% Preheater
% Preheater is created

%% Heat exchanger
% cs.he.st1_i = cs.st1(2);
% cs.he.st1_o = cs.st1(3);
% cs.he.st2_i = cs.st2(11);
% cs.he.st2_o = cs.st2(1);

% cs.calculate;