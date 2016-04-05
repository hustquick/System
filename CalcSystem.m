function F = CalcSystem(x, tb, ge)
%CalcSystem Use expressions to calculate some parameters of the system
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways
%     x = zeros(sea.n1,2);
tb.st_i.q_m.v = x(1);

F = [tb.P - ge.P / ge.eta];
end

