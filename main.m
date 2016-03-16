clear;
%%%%%%%%%%%%%BASIC DESIGN PARAMETERS%%%%%%%%%%%%%%%%%%%%
% Fluid names
% global F1 F2 F3 p_dr
Fluid = cellstr(char('Air', 'Water', 'Therminol_VP1'));	% Fluids

% Flow Type of the two fluids in Stirling engine array
FlowType = cellstr(char('Parallel', 'Counter'));

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
% p_da = 1e6;      % Pressure of deareator, Pa

ap = AirPipe;
    ap.d_i = 0.07;
    ap.delta_a = 0.005;
    ap.p = 5e5;
    ap.alpha = 0.87;
    ap.p = 5e5;
amb = Ambient;
    amb.I_r = 700;
    amb.p = 1e5;
    amb.T = C2K(20);
    amb.w = 4;
    amb.fluid = char(Fluid(1));
il = InsLayer;
    il.delta = 0.075;
    il.d_i = 0.46;
    il.epsilon = 0.6
    il.lambda = 0.06;

dc = DishCollector
    dc.fluidType = char(Fluid(1));
    dc.A = 87.7;
    dc.q_m = 0.0892;    % To be calculated
%     dc.T_cav = 1316;    % To be calculated
    dc.T_i = C2K(350);
    dc.T_o = C2K(800);
    dc.d_ap = 0.184;
    dc.d_cav = 0.46;
    dc.dep_cav = 0.23;
    dc.theta = Deg2Rad(45);
    dc.gamma = 0.97;
    dc.shading = 0.95;
    dc.rho = 0.91;
    dc.airPipe = ap;
    dc.ambient = amb;
    dc.insLayer = il;
    
% q_dr_1 = dc.get_q_dr_1();
% q_ref = dc.get_q_ref(amb);

% q_cond_conv = dc.get_q_cond_conv(T_ins, amb);
% q_cond_rad = dc.get_q_cond_rad(T_ins, amb);
% q_cond_tot = dc.get_q_cond_tot(T_ins);
% q_cond_tot = q_cond_conv + q_cond_rad;

% q_cond_conv = dc.get_q_cond_conv(T_ins, amb);
% q_cond_rad = dc.get_q_cond_rad(T_ins, amb);
% q_cond_tot = dc.get_q_cond_tot(T_ins);
% q_cond_tot1 = q_cond_conv + q_cond_rad;
% q_conv_tot = dc.get_q_conv_tot(amb);
% q_rad_emit = dc.get_q_rad_emit(amb);
% q_in = dc.get_q_in(amb);
% q_in1 = q_dr_1 + q_ref + (q_cond_tot + q_conv_tot + q_rad_emit);
guess = [400] ;
options = optimset('Display','iter');
[T_ins,fval] = fsolve(@(T_ins)solve(T_ins, dc, amb),guess,options);
