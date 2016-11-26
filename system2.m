clear;
% This system is the cascade system with both Stirling cycle and Rankine
% Cycle, without heat exchanger between the air and the water.
%% Get results matrix
number = 1;
cs = CascadeSystem2.empty;
ss = SeparateSystem2.empty;
eta_diff = zeros(1,number);
ratio = zeros(1,number);
used = zeros(1,number);
for k = 1:number
%% Connection and State points
cs(k) = CascadeSystem2;
ss(k) = SeparateSystem2;
cs(k).initialize();
%% Design parameters
cs(k).sea.n1 = 1;
cs(k).sea.n2 = 1;
cs(k).sea.order = 'Same';

cs(k).dca.n = cs(k).sea.n2;

cs(k).dca.dc.amb.I_r = 600 + 5 * (k - 1);
cs(k).dca.dc.st_i.fluid = char(Const.Fluid(1));
cs(k).dca.dc.st_i.T.v = convtemp(350, 'C', 'K');   % Design parameter
cs(k).dca.dc.st_i.p.v = 5e5;
cs(k).dca.dc.st_o.T.v = convtemp(800, 'C', 'K');

cs(k).tca.tc.amb.I_r = cs(k).dca.dc.amb.I_r;

cs(k).tca.st_o.fluid = char(Const.Fluid(3));
cs(k).tca.st_o.T.v = convtemp(380, 'C', 'K');
cs(k).tca.st_o.p = Pressure(2e6);

cs(k).tb.st_i.fluid = char(Const.Fluid(2));
cs(k).tb.st_i.T.v = convtemp(340, 'C', 'K');
cs(k).tb.st_i.p = Pressure(2.35e6);
cs(k).tb.st_o_2.p = Pressure(1.5e4);

cs(k).ge.P = 1.5e3;
cs(k).ge.eta = 0.975;

cs(k).da.p = Pressure(1e6);

cs(k).DeltaT_3_2 = 15;          % Minimun temperature difference between oil
%and water

%% Work
cs(k).calculate();

%% Seperate System Part
ss(k).initialize();

%% Design parameters
for i = 1 : 9
    ss(k).st2(i).fluid = char(Const.Fluid(2));
end
ss(k).dca.n = cs(k).dca.n;
ss(k).dca.dc.amb = cs(k).dca.dc.amb;
ss(k).dca.dc.st_i.fluid = cs(k).dca.dc.st_i.fluid;
ss(k).dca.dc.st_i.T.v = cs(k).dca.dc.st_i.T.v;
ss(k).dca.eta = cs(k).dca.eta;
ss(k).ge.eta = cs(k).ge.eta;
ss(k).tb.st_i.T = cs(k).tb.st_i.T;
ss(k).tb.st_i.p = cs(k).tb.st_i.p;
ss(k).tb.st_o_2.p = cs(k).tb.st_o_2.p;
ss(k).da.p = cs(k).da.p;
ss(k).DeltaT_3_2 = cs(k).DeltaT_3_2;

ss(k).calculate(cs(k));
%% Comparison
eta_diff(k) = (cs(k).eta - ss(k).eta) ./ ss(k).eta;
ratio(k) = cs(k).sea.P ./ cs(k).ge.P;
used(k) = (cs(k).sea.P ./ cs(k).sea.eta) ./ (cs(k).dca.n .* ...
    cs(k).dca.dc.q_tot .* cs(k).dca.eta);
end
