function F = CalcSEA(x, se)
%CalcSEA Use expressions to calculate Temperatures of Stirling Engine Array
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways 
%     x = zeros(length(se),2);
    for i = 1:length(se)
        se(i).st1_o.T.v = x(i, 1);
        se(i).st2_o.T.v = x(i, 2);
    end
    F = zeros(length(se),2);
    for j = 1:length(se)
        F(j,1) = 1 - se(j).eta1() ./ se(j).eta2();
        F(j,2) = 1 - se(j).P1() ./ se(j).P2();
    end
end