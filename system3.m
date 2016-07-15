clear;
% This system is the cascade system with two stages of Rankine cycle using
% different types of organic fluids.
%% Get results matrix
number = 2;
cs(number) = CascadeSystem3;
ss(number) = SeparateSystem3;
eta_diff = zeros(1,number);
used = zeros(1,number);
for k = 1 : number

%% Connection and State points
cs(k).initialize();
cs(k).sea.n1 = 1;
cs(k).sea.n2 = 3;
cs(k).sea.order = 'Same';

cs(k).dca.n = 1;
cs(k).dca.dc.amb.I_r = 330 + k * 70;
cs(k).dca.dc.st_i.fluid = char(Const.Fluid(1));
cs(k).dca.dc.st_i.T = Temperature(convtemp(500, 'C', 'K'));   % Design parameter
cs(k).dca.dc.st_i.p.v = 5e5;
cs(k).dca.dc.st_o.T = Temperature(convtemp(800, 'C', 'K'));

cs(k).tca.tc.amb.I_r = cs(k).dca.dc.amb.I_r;

cs(k).tca.st_o.fluid = char(Const.Fluid(3));
cs(k).tca.st_o.T = Temperature(convtemp(380, 'C', 'K'));
cs(k).tca.st_o.p.v = 2e6;

cs(k).otb1.fluid_d = char(Const.Fluid(4));
cs(k).otb1.T_s_d = Temperature(convtemp(300, 'C', 'K'));
cs(k).otb1.p_s_d = 2.8842e6;
cs(k).otb1.T_c_d = Temperature(convtemp(228.85, 'C', 'K'));
cs(k).otb1.p_c_d = 0.3605e6;
cs(k).otb1.st_i.fluid = cs(k).otb1.fluid_d;
cs(k).otb1.st_i.T = Temperature(convtemp(300, 'C', 'K'));
cs(k).otb1.st_i.p.v = 2.8842e6;
cs(k).otb1.st_o.p.v = 0.3605e6;

cs(k).otb2.fluid_d = char(Const.Fluid(5));
cs(k).otb2.T_s_d = Temperature(convtemp(141.152, 'C', 'K'));
cs(k).otb2.p_s_d = 1e6;
cs(k).otb2.T_c_d = Temperature(convtemp(91.35, 'C', 'K'));
cs(k).otb2.p_c_d = 0.167e6;
cs(k).otb2.st_i.fluid = cs(k).otb2.fluid_d;
cs(k).otb2.st_i.T = Temperature(convtemp(141.152, 'C', 'K'));
cs(k).otb2.st_i.p.v = 1e6;
cs(k).otb2.st_o.p.v = 0.167e6;

cs(k).oge1.eta = 0.975;
cs(k).oge2.P = 140e3;
cs(k).oge2.eta = 0.975;
cs(k).DeltaT_1_2 = 15;
cs(k).DeltaT_3_4 = 15;          % Minimun temperature difference between oil
%and water

%% Work
cs(k).calculate();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seperate System Part
ss(k) = SeparateSystem3;
ss(k).initialize();

ss(k).dca.n = cs(k).dca.n;
ss(k).dca.dc.amb = cs(k).dca.dc.amb;
ss(k).dca.eta = cs(k).dca.eta;
ss(k).ge.eta = cs(k).oge1.eta;
ss(k).DeltaT_3_4 = cs(k).DeltaT_3_4;

ss(k).otb.st_i.T.v = cs(k).otb1.st_i.T.v;
ss(k).otb.st_i.p = cs(k).otb1.st_i.p;
ss(k).otb.st_o.p = cs(k).otb1.st_o.p;

ss(k).calculate(cs(k));
%% Comparison
eta_diff(k) = (cs(k).eta - ss(k).eta) ./ ss(k).eta;
used(k) = (cs(k).sea.P ./ cs(k).sea.eta) ./ (cs(k).dca.n .* cs(k).dca.dc.q_tot);
end
