clear;

% Fluid names
% global F1 F2 F3 p_dr

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

%%%%%%%%%%%%%Dish Collector Part%%%%%%%%%%%%%%%

amb = Ambient;
    amb.I_r = 700;
    amb.p = 1e5;
    amb.T = Temperature(C2K(20));
    amb.w = 4;
    amb.fluid = char(Const.Fluid(1));

st1(3) = Stream;

st1(1).fluid = char(Const.Fluid(1));
st1(1).T = Temperature(C2K(800));
st1(1).p = 5e5;
    
ap = AirPipe;
    ap.d_i = 0.07;
    ap.delta_a = 0.005;
    ap.alpha = 0.87;
il = InsLayer;
    il.delta = 0.075;
    il.d_i = 0.46;
    il.epsilon = 0.6;
    il.lambda = 0.06;

st_dc_i = Stream;
    st_dc_i.fluid = char(Const.Fluid(1));
    st_dc_i.T = Temperature(C2K(350));
    st_dc_i.p = 5e5;
    
st_dc_o = Stream.flow(st_dc_i);
    st_dc_o.T = Temperature(C2K(800));
    st_dc_o.p = st_dc_i.p;
    
dc = DishCollector;
    dc.A = 87.7;
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
n1 = 8;                % Column number of Stirling engine array
n2 = Const.NUM_SE / n1; % Row number of Stirling engine array
guess2 = zeros(2,n1);   % 2 * n1 unknown parameters (outlet temperature of two fluids in each column)

q_m_1 = 2.990;  % To be calculated!
q_m_2 = 5.625;  % To be calculated;

st1_se_i = dc.st_o;            % Not right for the q_m, so next line corrects the q_m
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
se(1).st1_o = Stream.flow(se(1).st1_i);
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
    se(n1).st2_o = Stream.flow(se(n1).st2_i);
        se(n1).st2_o.p = se(n1).st2_i.p;    
    
    for i = 1:n1-1
        se(i+1).st1_i = se(i).st1_o;
        se(n1-i).st2_i = se(n1+1-i).st2_o;

        se(i+1).st1_o = Stream.flow(se(i+1).st1_i);
            se(i+1).st1_o.p = se(i+1).st1_i.p;
        se(n1-i).st2_o = Stream.flow(se(n1-i).st2_i);
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

P = zeros(n1,1);

for i = 1:n1
    se(i).st1_o.T.v = x2(i, 1);
    se(i).st2_o.T.v = x2(i, 2);
    se(i).P = se(i).P1();
    P(i) = se(i).P2();
end
if (strcmp(order, 'Same'))
    eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(n1).st2_o.T.v - se(1).st2_i.T.v)) / ...
    (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(n1).st1_o.T.v)); 
elseif (strcmp(order,'Reverse'))
    eta_ses1 = 1 - (st2_se_i.q_m.v * se_cp_2 * (se(1).st2_o.T.v - se(n1).st2_i.T.v)) / ...
    (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(n1).st1_o.T.v)); 
else
    error('Uncomplished work.');
end
eta_ses = sum(P) ./ (st1_se_i.q_m.v * se_cp_1 * (se(1).st1_i.T.v - se(n1).st1_o.T.v)); 

%%%%%%%%%%%%%Trough Collector Part%%%%%%%%%%%%%%%

tc = TroughCollector;
    tc.A = 545;
    tc.gamma = 0.93;
    tc.rho = 0.94;
    tc.shading = 1;
    tc.Fe = 0.97;
    tc.phi = Deg2Rad(70);
    tc.d_i = 0.066;
    tc.d_o = 0.07;
    tc.alpha = 0.96;
    tc.tau = 0.95;
    tc.w = 5.76;

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

st3_tc_i = Stream.flow(st3_tc_o);
    st3_tc_i.T = Temperature(C2K(225));
    st3_tc_i.p = st3_tc_o.p;

tc.st_i = st3_tc_i;
tc.st_o = st3_tc_o;
tc.eta = tc.get_eta(amb)
