function F = CalcSEA(x, se, dc, pp1)
%CalcSEA Use expressions to calculate Temperatures of Stirling Engine Array
%   First expression expresses eta of each Stirling engine in two ways
%   Second expression expresses P of each Stirling engine in two ways 
    F(1,1) = x(1,1) - dc.T_o;
    F(1,2) = x(1,3) - pp1.T_o;
    F(1,3) = se(1).eta1(x(1,1), x(1,2), x(1,3), x(1,4))
            - se(1).eta2(x(1,1), x(1,2), x(1,3), x(1,4));
    F(1,4) = se(1).P1(x(1,1), x(1,2), x(1,3), x(1,4))
            - se(1).P2(x(1,1), x(1,2), x(1,3), x(1,4));
    for i = 2:10
        F(i,1) = x(i,1) - x(i-1,2);
        F(i,2) = x(i,3) - x(i-1,4);
        F(i,3) = se(i).eta1(x(i,1), x(i,2), x(i,3), x(i,4))
            - se(i).eta2(x(i,1), x(i,2), x(i,3), x(i,4));
        F(i,4) = se(i).P1(x(i,1), x(i,2), x(i,3), x(i,4))
            - se(i).P2(x(i,1), x(i,2), x(i,3), x(i,4));
    end
end

