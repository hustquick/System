clear;
    
st1(3) = Stream;
    st1(1).fluid = char(Const.Fluid(1));
st2(11) = Stream;
    st2(1).fluid = char(Const.Fluid(2));
st3(4) = Stream;
    st3(1).fluid = char(Const.Fluid(3));
%% Dish Collector
% A dish collector is built under given ambient parameters
ap = AirPipe;
il = InsLayer;
amb = Ambient;

dc = DishCollector;
    dc.st_i.fluid = st1(1).fluid;
    dc.st_i.T = Temperature(convtemp(350, 'C', 'K'));
    dc.st_i.p = 5e5;
    
    dc.st_o = dc.st_i.flow();
    dc.st_o.T = Temperature(convtemp(800, 'C', 'K'));
    dc.st_o.p = dc.st_i.p;
    
    dc.amb = amb;
    dc.airPipe = ap;
    dc.insLayer = il;
    
    dc.calculate();

    ratio = 2.990 / dc.st_o.q_m.v;      % To be calculated  
    st1(1) = dc.st_o.converge(ratio);   
    st1(3) = dc.st_i.converge(ratio);   
%% Stirling Engine Array
% Two kinds of connection orders of the Stirling engines are considered.
st1(2) = st1(1).flow();

q_m_2 = Q_m(5.625);  % To be calculated;

st2(5).fluid = st2(1).fluid;
st2(5).T = Temperature(330);  % to be calculated
st2(5).p = 1e6;
st2(5).q_m = q_m_2; % to be calculated
st2(6) = st2(5).flow();

sea = SEA(10, 'Reverse');
    sea.st1_i = st1(1);
    sea.st1_o = st1(2);
    sea.st2_i = st2(5);
    sea.st2_o = st2(6);

sea.calculate();
%% Trough Collector
%

tc = TroughCollector;
tc.amb = Ambient;

st3(1).T = Temperature(convtemp(350, 'C', 'K'));
st3(1).p = 2e6;
st3(1).q_m.v = 53.41;  % To be calculated

st3(4) = st3(1).flow();
st3(4).T = Temperature(convtemp(225, 'C', 'K'));     % To be calculated
st3(4).p = st3(1).p;

tc.st_i = st3(4);
tc.st_o = st3(1);

da = Deaerator;
da.p = 1e6;

st2(11) = Stream;

st2(1).fluid = char(Const.Fluid(2));
st2(1).T = Temperature(convtemp(340, 'C', 'K'));
st2(1).p = 2.35e6;
st2(1).q_m.v = 6.672;  % To be calculated

st2(2).fluid = st2(1).fluid;
st2(2).p = 1.5e4;

st2(3).fluid = st2(1).fluid;
% st2(3).p = da.p;
st2(3).p = 1e6;
%% Turbine
% A steam turbine is created
tb = Turbine;
tb.st_i = st2(1);
tb.st_o_1 = st2(2);
tb.st_o_2 = st2(3);
tb.y = 0.1;
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
pu1.p = 1e6;
pu1.st_i = st2(4);
st2(5) = pu1.st_o;
%% Deaerator
% Deaerator is created
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