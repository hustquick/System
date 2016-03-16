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
    ap.alpha = 0.87;
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
    dc.p = 5e5;
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
    

guess = [1400; 400; 0.2] ;
options = optimset('Display','iter');
[x, fval] = fsolve(@(x)CalcDishCollector(x, dc, amb), guess, options);

dc.T_cav = x(1);
dc.T_ins = x(2);
dc.q_m = x(3);
dc.efficiency = dc.q_dr_1_h(dc.q_m) ./ dc.q_tot(amb);



