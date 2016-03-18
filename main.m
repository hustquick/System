clear;
%%%%%%%%%%%%%BASIC DESIGN PARAMETERS%%%%%%%%%%%%%%%%%%%%
% Fluid names
% global F1 F2 F3 p_dr


% Flow Type of the two fluids in Stirling engine array

% % Generator
% P_ge = 4e6;	% Power of generator, W
% eta_ge = 0.975;	% Efficiency of generator
% 
% % % Dish collector
% % T_dr_i = C2K(350) % Temperature of air at dish receiver inlet, K
% % T_dr_o = C2K(800)    % Temperature of air at dish receiver outlet, K
% % p_dr = 5e5  % Pressure of air in dish receiver, Pa
% 
% % Trough collector
% T_tr_o = C2K(350);   % Temperater of oil at trough receiver outlet, K
% DeltaT_2_3_min = 15; % Minimum temperature difference of oil and water, K
% p_tr = 2e6;  % Pressure of oil in trough receiver, Pa
% 
% % Stirling engine
% n_se = 100;  % Number of Stirling engines
% n_g = 0.078; % Amount of gas (H2) in each Stirling engine, mol
% T_se1_o = C2K(400);  % Temperature of air at outlet of Stirling engine array, K
% 
% % Steam turbine
% T_s = C2K(340);  % Main steam temperature of steam turbine, K
% p_s = 2.35e6;    % Main steam pressure of steam turbine, Pa
% p_c = 1.5e4;     % Exhaust pressure of steam turbine, Pa
% 
% % Deaerator

ap = AirPipe;
    ap.d_i = 0.07;
    ap.delta_a = 0.005;
    ap.alpha = 0.87;
amb = Ambient;
    amb.I_r = 700;
    amb.p = 1e5;
    amb.T = Temperature(C2K(20));
    amb.w = 4;
    amb.fluid = char(Const.Fluid(1));
il = InsLayer;
    il.delta = 0.075;
    il.d_i = 0.46;
    il.epsilon = 0.6;
    il.lambda = 0.06;

st_dc_i = Stream;
    st_dc_i.fluid = char(Const.Fluid(1));
%     st_dc_i.q_m = 0.1;
    st_dc_i.T = Temperature(C2K(350));
    st_dc_i.p = 5e5;
    
st_dc_o = Stream.flow(st_dc_i);
    st_dc_o.T = Temperature(C2K(800));
    st_dc_o.p = st_dc_i.p;
    
dc = DishCollector;
    dc.A = 87.7;
%     dc.p = 5e5;
%     dc.T_i = C2K(350);
%     dc.T_o = C2K(800);
    dc.gamma = 0.97;
    dc.shading = 0.95;
    dc.rho = 0.91;
    dc.st_i = st_dc_i;
    dc.st_o = st_dc_o;
    dc.d_ap = 0.184;
    dc.d_cav = 0.46;
    dc.dep_cav = 0.23;
    dc.theta = Deg2Rad(45);

    dc.airPipe = ap;
    dc.ambient = amb;
    dc.insLayer = il;

    guess1 = [1500; 400; 0.2] ;
    options = optimset('Display','iter');
    [x1, fval1] = fsolve(@(x1)CalcDishCollector(x1, dc, amb), ...
        guess1, options);
    
dc.eta = dc.q_dr_1_1() ./ dc.q_tot(amb);

%%%%%%%%%%%%%Stirling Engine Array Part%%%%%%%%%%%%%%%

order = 'Reverse'; % can be 'Same', 'Reverse' and other types, n_1! types all together
guess2 = zeros(2,10);

st1_se_i = Stream; %#ok<NASGU>
    st1_se_i = dc.st_o;            % Not right for the q_m, so next line corrects the q_m
    st1_se_i.q_m.v = 0.3244;      % To be calculated!
se_cp_1 = CoolProp.PropsSI('C', 'T', st1_se_i.T.v, 'P', ...
    st1_se_i.p, st1_se_i.fluid);
    
st2_se_i = Stream;
    st2_se_i.fluid = char(Const.Fluid(2));
    st2_se_i.T = Temperature(327.2);
    st2_se_i.p = 1e6;
        st2_se_i.q_m.v = 0.5629;     % To be calculated!
se_cp_2 = CoolProp.PropsSI('C', 'T', st2_se_i.T.v, 'P', ...
        st2_se_i.p, st2_se_i.fluid);

se(1,10) = StirlingEngine;

se(1) = StirlingEngine;
se(1).flowType = order; % can be changed
se(1).st1_i = st1_se_i;
se(1).st1_o = Stream.flow(se(1).st1_i);
    se(1).st1_o.p = se(1).st1_i.p;
se(1).cp_1 = se_cp_1;

if (strcmp(order, 'Same'))
    %%%%% Same order %%%%%
    se(1).st2_i = st2_se_i;
    se(1).st2_o = Stream.flow(se(1).st2_i);
        se(1).st2_o.p = se(1).st2_i.p;    
    se(1).cp_2 = se_cp_2;
    for i = 2:10
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

    for j = 1:10
        guess2(j,1) = se(1).st1_i.T.v - 40 * j;
        guess2(j,2) = se(1).st2_i.T.v + 4 * j;
    end
elseif (strcmp(order,'Reverse'))
    %%%%% Inverse order %%%%%
    se(1).cp_2 = se_cp_2;
    for i = 2:10
        se(i) = StirlingEngine;
            se(i).flowType = se(1).flowType; % Flowtype of any Stirling engine can be changed seperately
            se(i).cp_1 = se_cp_1;
            se(i).cp_2 = se_cp_2;
    end
    se(10).st2_i = st2_se_i;
    se(10).st2_o = Stream.flow(se(10).st2_i);
        se(10).st2_o.p = se(10).st2_i.p;    
    
    for i = 1:9
        se(i+1).st1_i = se(i).st1_o;
        se(10-i).st2_i = se(11-i).st2_o;

        se(i+1).st1_o = Stream.flow(se(i+1).st1_i);
            se(i+1).st1_o.p = se(i+1).st1_i.p;
        se(10-i).st2_o = Stream.flow(se(10-i).st2_i);
            se(10-i).st2_o.p = se(10-i).st2_i.p;
    end
    
    for j = 1:10
        guess2(j,1) = se(1).st1_i.T.v - 30 * j;
        guess2(j,2) = se(10).st2_i.T.v + 4 * (11 - j);
    end
else
    error('Uncomplished work.');
end

[x2, fval2] = fsolve(@(x2)CalcSEA(x2, se), guess2, options);

P = zeros(10,1);

for i = 1:10
    se(i).st1_o.T.v = x2(i, 1);
    se(i).st2_o.T.v = x2(i, 2);
    se(i).P = se(i).P1();
    P(i) = se(i).P2();
end
if (strcmp(order, 'Same'))
    eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(10).st2_o.T.v - se(1).st2_i.T.v)) / ...
    (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(10).st1_o.T.v)); 
elseif (strcmp(order,'Reverse'))
    eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(1).st2_o.T.v - se(10).st2_i.T.v)) / ...
    (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(10).st1_o.T.v)); 
else
    error('Uncomplished work.');
end
eta_ses = sum(P) ./ (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(10).st1_o.T.v)); 
