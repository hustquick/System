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
pp1.p = 1e6;      % Pressure of deareator, Pa
pp1.T_o = Temperature(327.2);     % Outlet temperature of pump 1
pp1.fluid = Const.Fluid(2);

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
    il.epsilon = 0.6
    il.lambda = 0.06;

st_dc_i = Stream;
    st_dc_i.fluid = char(Const.Fluid(1));
    st_dc_i.q_m = 0.1;
    st_dc_i.T = Temperature(C2K(350));
    st_dc_i.p = 5e5;
    
st_dc_o = Stream.flow(st_dc_i);
    st_dc_o.T = Temperature(C2K(800));
    st_dc_o.p = st_dc_i.p;
    
dc = DishCollector
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
    
    dc.T_ins.v = 340;   % Test only
    dc.T_p.v = 1400;      % Test only

    guess = [1400; 400; 0.2] ;
    options = optimset('Display','iter');
    [x, fval] = fsolve(@(x)CalcDishCollector(x, dc, amb), guess, options);
% 
% dc.T_p = x(1);
% dc.T_ins = x(2);
% dc.q_m = x(3);
% dc.eta = dc.q_dr_1_h(dc.q_m) ./ dc.q_tot(amb);
% 
% for i = 1:11
%     st_se1(i) = Stream;
%     st_se1(i).fluid = char(Const.Fluid(1));
%     st_se1(i).p = dc.p;
%     st_se1(i).q_m = 0.3895;
%     st_se1(i).T = Temperature;
%     st_se2(i) = Stream;
%     st_se2(i).fluid = char(Const.Fluid(2));
%     st_se2(i).p = pp1.p;
%     st_se2(i).q_m = 0.5632;
%     st_se2(i).T = Temperature;
% end
% 
% cp_1 = CoolProp.PropsSI('C', 'T', dc.T_o, 'P', dc.p, dc.fluidType);
% cp_2 = CoolProp.PropsSI('C', 'T', pp1.T_o, 'P', pp1.p, pp1.fluid);
% 
% for j = 1:10
%     se(j) = StirlingEngine;
%     se(j).cp_1 = cp_1;
%     se(j).cp_2 = cp_2;
%     se(j).T_1_i = Temperature;
%     se(j).T_1_o = Temperature;
%     se(j).T_2_i = Temperature;
%     se(j).T_2_o = Temperature;
% end
% 
% %%%%% Same order %%%%%
% 
% % st_se1(11).T = C2K(400);
% 
% for i = 1:10
%     guess1(i,1) = dc.T_o - 20 * (i - 1);
%     guess1(i,2) = dc.T_o - 20 * i;
%     guess1(i,3) = pp1.T_o + 4 * (i - 1);
%     guess1(i,4) = pp1.T_o + 4 * i;
% end
% 
% for j = 1:10
%     se(j).InletStream1(st_se1(j));
%     se(j).InletStream2(st_se2(j));
%     se(j).OutletStream1(st_se1(j+1));
%     se(j).OutletStream2(st_se2(j+1));
% end
% 
% [x2, fval] = fsolve(@(x2)CalcSEA(x2, se, dc, pp1), guess1, options);
% 
% for i = 1:10
%     se(i).T_1_i.v = x2(i,1);
%     se(i).T_1_o.v = x2(i,2);
%     se(i).T_2_i.v = x2(i,3);
%     se(i).T_2_o.v = x2(i,4);
%     se(i).P = se(i).P2(x2(i,1), x2(i,2), x2(i,3), x2(i,4));
%     P(i) = se(i).P1(x2(i,1), x2(i,2), x2(i,3), x2(i,4));
%     T_H(i) = se(i).T_H(x2(i,1), x2(i,2), x2(i,3), x2(i,4));
%     
% end