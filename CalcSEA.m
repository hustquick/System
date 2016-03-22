function F = CalcSEA(x, sea)
%CalcSEA Use expressions to calculate Temperatures of Stirling Engine Array
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways
%     x = zeros(sea.n1,2);
for i = 1 : sea.n1
    sea.se(i).st1_o.T.v = x(i, 1);
    sea.se(i).st2_o.T.v = x(i, 2);
end
F = zeros(sea.n1,2);
for j = 1 : sea.n1
    F(j,1) = 1 - sea.se(j).eta1() ./ sea.se(j).eta2();
    F(j,2) = 1 - sea.se(j).P1() ./ sea.se(j).P2();
end
end