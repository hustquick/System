clear;

st1(3) = Stream;
st1(1).fluid = char(Const.Fluid(1));
st1(1).T = Temperature(convtemp(800, 'C', 'K'));
st1(1).p = 5e5;      % Design parameter, air pressure in dish receiver, Pa
st1(3).T = Temperature(convtemp(350, 'C', 'K'));   % Design parameter
st2(11) = Stream;
st2(1).fluid = char(Const.Fluid(2));
st2(1).T = Temperature(convtemp(340, 'C', 'K'));
st2(1).p = 2.35e6;
st2(2).fluid = st2(1).fluid;
st2(2).p = 1.5e4;
st2(3).fluid = st2(1).fluid;
st3(4) = Stream;
st3(1).fluid = char(Const.Fluid(3));
st3(1).p = 2e6;
st3(1).T = Temperature(convtemp(350, 'C', 'K'));    % Design parameter

ge_P = 4e6;             % Power of generator, W
ge_eta = 0.975;         % Efficiency of generator
da_p = 1e6;             % Design parameter, deaerator pressure, Pa
n1 = 10;                % Can be optimized
%% Dish Collector
% A dish collector is built under given ambient parameters
ap = AirPipe;
il = InsLayer;
amb = Ambient;

dc = DishCollector;
dc.st_o.fluid = st1(1).fluid;
dc.st_o.T = st1(1).T;
dc.st_o.p = st1(1).p;

dc.st_i = dc.st_o.flow();
dc.st_i.T = st1(3).T;
dc.st_i.p = st1(1).p;

dc.amb = amb;
dc.airPipe = ap;
dc.insLayer = il;

dc.calculate();

st1(1).q_m = Q_m(2.990);               % To be calculated
ratio = st1(1).q_m.v / dc.st_o.q_m.v;
st1(1) = dc.st_o.converge(ratio);
st1(3) = dc.st_i.converge(ratio);
%% Generator
% A generator is created
ge = Generator;
ge.P = ge_P;
ge.eta = ge_eta;
%% Turbine
% A steam turbine is created
st2(1).q_m = Q_m(6.672);               % To be calculated
st2(3).p = da_p;
tb = Turbine;
tb.st_i = st2(1);
tb.st_o_1 = st2(2);
tb.st_o_2 = st2(3);
st2(2).q_m = Q_m(5.625);            % To be calculated
% tb.y = (st2(1).q_m.v - st2(5).q_m.v) ./ st2(1).q_m.v;
tb.calculate();
st2(2) = tb.st_o_1;    % Necessary for the stream has been diverged in the turbine
st2(3) = tb.st_o_2;    % Necessary for the stream has been diverged in the turbine
%% Condenser
% A condenser is created
cd = Condenser;
cd.st1 = st2(2);
st2(4) = cd.st2;
%% Pump1
% Pump 1 is used to raise the pressure of water to 1MPa
pu1 = Pump;
pu1.p = da_p;
pu1.st_i = st2(4);
st2(5) = pu1.st_o;
%% Stirling Engine Array
% Two kinds of connection orders of the Stirling engines are considered.
st1(2) = st1(1).flow();
st2(6) = st2(5).flow();

sea = SEA(n1, 'Reverse');
sea.st1_i = st1(1);
sea.st1_o = st1(2);
sea.st2_i = st2(5);
sea.st2_o = st2(6);

sea.calculate();
%% Trough Collector
% Trough collector is created

tc = TroughCollector;
tc.amb = Ambient;

st3(1).q_m = Q_m(53.41);  % To be calculated

st3(4) = st3(1).flow();
st3(4).T = Temperature(convtemp(225, 'C', 'K'));     % To be calculated
st3(4).p = st3(1).p;

tc.st_i = st3(4);
tc.st_o = st3(1);
%% Deaerator
% Deaerator is created
da = Deaerator;
da.p = da_p;
da.st_i_1 = st2(3);
da.st_i_2 = st2(6);
st2(7) = da.st_o;
%% Pump2
% Pump 2 is used to raise the pressure of water to the main pressure
pu2 = Pump;
pu2.p = tb.st_i.p;
pu2.st_i = st2(7);
st2(8) = pu2.st_o;
%% Preheater
% Preheater is created
ph = Preheater;
ph.st1_i = st2(8);
st2(9) = ph.st1_o;
ph.st2_o = tc.st_i;
ph.calculate();
st3(3) = ph.st2_i;
st3(4) = ph.st2_o;
%% Evaporator
% Evaporator is created
ev = Evaporator;
ev.st1_i = st2(9);
st2(10) = ev.st1_o;
ev.st2_o = st3(3);
ev.calculate();
st3(2) = ev.st2_i;
%% Superheater
% Superheater is created
sh = Superheater;
sh.st1_i = st2(10);
sh.st2_i = st3(1);
sh.st2_o = st3(2);
st2(11) = sh.st1_o;
%% HeatExchanger
% Air-water heat exchanger is created
he = HeatExchanger;
he.st1_i = st1(2);
he.st1_o = st1(3);
he.st2_i = st2(11);
he.st2_o = st2(1);
he.st2_q_m;
%% Cascade System Calculation
guess = [6.672];
options = optimset('Display','iter');
[x] = fsolve(@(x)CalcSystem(x, tb, ge), ...
                guess, options);