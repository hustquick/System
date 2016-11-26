clear;
% This is the model for the test platform
%% ORC turbine
pf = Platform;
pf.initialize();

pf.sea.n1 = 1;
pf.sea.n2 = 1;

pf.tca.tc.amb.I_r = 400;

pf.tca.st_i.fluid = char(Const.Fluid(3));
pf.tca.st_i.T.v = convtemp(160, 'C', 'K');
pf.tca.st_i.p.v = 3e6;
pf.tca.st_i.q_m.v = 0.44;

pf.orcSystem.P = 1500;



