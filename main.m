clear;

%% Dish Collector
% A dish collector is built under given ambient parameters

amb = Ambient;

st1(3) = Stream;

st1(1).fluid = char(Const.Fluid(1));
st1(1).T = Temperature(C2K(800));
st1(1).p = 5e5;

ap = AirPipe;
il = InsLayer;

st_dc_i = Stream;
st_dc_i.fluid = char(Const.Fluid(1));
st_dc_i.T = Temperature(C2K(350));
st_dc_i.p = 5e5;

st_dc_o = st_dc_i.flow();
st_dc_o.T = Temperature(C2K(800));
st_dc_o.p = st_dc_i.p;

dc = DishCollector;
dc.amb = amb;
dc.st_i = st_dc_i;
dc.st_o = st_dc_o;
dc.airPipe = ap;
dc.insLayer = il;

guess1 = [1500; 400; 0.1] ;
options = optimset('Display','iter');
[x1, fval1] = fsolve(@(x1)CalcDishCollector(x1, dc), ...
    guess1, options);
dc
%% Stirling Engine Array
% Two kinds of connection orders of the Stirling engines are considered.

order = 'Reverse'; % can be 'Same', 'Reverse' and other types, n_1! types all together
n1 = 10;                % Column number of Stirling engine array
n2 = Const.NUM_SE / n1; % Row number of Stirling engine array
guess2 = zeros(2,n1);   % 2 * n1 unknown parameters (outlet temperature of two fluids in each column)

q_m_1 = 2.990;  % To be calculated!
q_m_2 = 5.625;  % To be calculated;

% st1_se_i = dc.st_o;            % Not right for the q_m, so next line corrects the q_m
st1_se_i = Stream;              % to be changed!!!!!
st1_se_i.fluid = char(Const.Fluid(2));
st1_se_i.T.v = dc.st_o.T.v;
st1_se_i.p = dc.st_o.p;
st1_se_i.q_m.v = q_m_1 / n2;
se_cp_1 = CoolProp.PropsSI('C', 'T', st1_se_i.T.v, 'P', ...
    st1_se_i.p, st1_se_i.fluid);

st2_se_i = Stream;
st2_se_i.fluid = char(Const.Fluid(2));
st2_se_i.T = Temperature(327.2);
st2_se_i.p = 1e6;
st2_se_i.q_m.v = q_m_2 / n2;
se_cp_2 = CoolProp.PropsSI('C', 'T', st2_se_i.T.v, 'P', ...
    st2_se_i.p, st2_se_i.fluid);

se(1,n1) = StirlingEngine;

se(1) = StirlingEngine;
se(1).flowType = order; % can be changed
se(1).st1_i = st1_se_i;
se(1).st1_o = se(1).st1_i.flow();
se(1).st1_o.p = se(1).st1_i.p;
se(1).cp_1 = se_cp_1;

if (strcmp(order, 'Same'))
    %%%%% Same order %%%%%
    se(1).st2_i = st2_se_i;
    se(1).st2_o = Stream.flow(se(1).st2_i);
    se(1).st2_o.p = se(1).st2_i.p;
    se(1).cp_2 = se_cp_2;
    for i = 2:n1
        se(i) = StirlingEngine;
        se(i).flowType = se(1).flowType;    % Flowtype of any Stirling engine can be changed seperately
        se(i).cp_1 = se_cp_1;
        se(i).cp_2 = se_cp_2;
        se(i).st1_i = se(i-1).st1_o;
        se(i).st2_i = se(i-1).st2_o;
        se(i).st1_o = Stream.flow(se(i).st1_i);
        se(i).st1_o.p = se(i).st1_i.p;
        se(i).st2_o = Stream.flow(se(i).st2_i);
        se(i).st2_o.p = se(i).st2_i.p;
    end
    
    for j = 1:n1
        guess2(j,1) = se(1).st1_i.T.v - 40 * j;
        guess2(j,2) = se(1).st2_i.T.v + 4 * j;
    end
elseif (strcmp(order,'Reverse'))
    %%%%% Inverse order %%%%%
    se(1).cp_2 = se_cp_2;
    for i = 2:n1
        se(i) = StirlingEngine;
        se(i).flowType = se(1).flowType; % Flowtype of any Stirling engine can be changed seperately
        se(i).cp_1 = se_cp_1;
        se(i).cp_2 = se_cp_2;
    end
    se(n1).st2_i = st2_se_i;
    se(n1).st2_o = se(n1).st2_i.flow();
    se(n1).st2_o.p = se(n1).st2_i.p;
    
    for i = 1:n1-1
        se(i+1).st1_i = se(i).st1_o;
        se(n1-i).st2_i = se(n1+1-i).st2_o;
        
        se(i+1).st1_o = se(i+1).st1_i.flow();
        se(i+1).st1_o.p = se(i+1).st1_i.p;
        se(n1-i).st2_o = se(n1-i).st2_i.flow();
        se(n1-i).st2_o.p = se(n1-i).st2_i.p;
    end
    
    for j = 1:n1
        guess2(j,1) = se(1).st1_i.T.v - 30 * j;
        guess2(j,2) = se(n1).st2_i.T.v + 4 * (n1 + 1 - j);
    end
else
    error('Uncomplished work.');
end

[x2, fval2] = fsolve(@(x2)CalcSEA(x2, se), guess2, options);
%%%%%%%%%%%%%%%%%% For comparison!!  %%%%%%%%%%%%%%%%%
%
% if (strcmp(order, 'Same'))
%     eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(n1).st2_o.T.v - ...
%         se(1).st2_i.T.v)) / (st1_se_i.q_m.v * se_cp_1 * ...
%         (se(1).st1_i.T.v - se(n1).st1_o.T.v));
% elseif (strcmp(order,'Reverse'))
%     eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(1).st2_o.T.v - ...
%         se(n1).st2_i.T.v)) / (st1_se_i.q_m.v * se_cp_1 * ...
%         (se(1).st1_i.T.v - se(n1).st1_o.T.v));
% else
%     error('Uncomplished work.');
% end

P = zeros(n1,1);

for i = 1:n1
    se(i).st1_o.T.v = x2(i, 1);
    se(i).st2_o.T.v = x2(i, 2);
    se(i).P = se(i).P1();
    P(i) = se(i).P2();
end
eta_ses = sum(P) ./ (st1_se_i.q_m.v * se_cp_1 * ...
    (se(1).st1_i.T.v - se(n1).st1_o.T.v));
P
eta_ses
%% Trough Collector
%

amb = Ambient;
tc = TroughCollector;
tc.amb = amb;

st3(4) = Stream;

st3(1).fluid = char(Const.Fluid(3));
st3(1).T = Temperature(C2K(400));
st3(1).p = 2e6;
st3(1).q_m.v = 53.41;  % To be calculated

st3_tc_o = Stream;
st3_tc_o.fluid = char(Const.Fluid(3));
st3_tc_o.T = Temperature(C2K(350));
st3_tc_o.p = 2e6;
st3_tc_o.q_m.v = 3.41;  % To be calculated

st3_tc_i = st3_tc_o.flow();
st3_tc_i.T = Temperature(C2K(225));
st3_tc_i.p = st3_tc_o.p;

tc.st_i = st3_tc_i;
tc.st_o = st3_tc_o;

da = Deaerator;
da.p = 1e6;

st2(11) = Stream;

st2(1).fluid = char(Const.Fluid(2));
st2(1).T = Temperature(C2K(340));
st2(1).p = 2.35e6;
st2(1).q_m.v = 6.672;  % To be calculated

st2(2).fluid = st2(1).fluid;
st2(2).p = 1.5e4;

st2(3).fluid = st2(1).fluid;
% st2(3).p = da.p;
st2(3).p = 1e6;
tc
%% Turbine
% A steam turbine is created
tb = Turbine;
tb.st1 = st2(1);
tb.st2 = st2(2);
tb.st3 = st2(3);
tb.y = 0.1;
tb.calculate();
st2(2) = tb.st2;    % Necessary for the stream has been diverged in the turbine
st2(3) = tb.st3;    % Necessary for the stream has been diverged in the turbine
tb
%% Condensor
% A condensor is created
cd = Condensor;
cd.st1 = st2(2);
cd.st2;
cd
%%
